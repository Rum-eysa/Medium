import uuid
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User
from app.models.refresh_token import RefreshToken
from app.schemas.auth import RegisterRequest, LoginRequest, TokenResponse
from app.schemas.user import UserRead
from app.core.security import (
    hash_password, verify_password,
    create_access_token, create_refresh_token, decode_token,
)
from app.core.config import settings
from app.core.exceptions import (
    UnauthorizedException, ConflictException, NotFoundException
)

logger = logging.getLogger(__name__)


class AuthService:

    def __init__(self, db: AsyncSession):
        self.db = db

    # ── US-001: Kayit ────────────────────────────────────────────────────────

    async def register(self, req: RegisterRequest) -> TokenResponse:
        """E-posta ve sifre ile yeni kullanici olusturur."""
        # Duplicate kontrol
        existing_email = await self.db.execute(
            select(User).where(User.email == req.email)
        )
        if existing_email.scalar_one_or_none():
            raise ConflictException("Bu e-posta adresi zaten kayitli.")

        existing_username = await self.db.execute(
            select(User).where(User.username == req.username.lower())
        )
        if existing_username.scalar_one_or_none():
            raise ConflictException("Bu kullanici adi zaten alinmis.")

        # Kullanici olustur
        user = User(
            id=str(uuid.uuid4()),
            email=req.email,
            username=req.username.lower(),
            hashed_password=hash_password(req.password),
            display_name=req.display_name or req.username,
            is_verified=True,  # Simdilik dogrulanmis kabul et; ileride email dogrulama eklenecek
        )
        self.db.add(user)
        await self.db.flush()

        return await self._issue_tokens(user)

    # ── US-002: Giris ────────────────────────────────────────────────────────

    async def login(self, req: LoginRequest) -> TokenResponse:
        """E-posta ve sifre ile giris yapar, token cifti doner."""
        r = await self.db.execute(select(User).where(User.email == req.email))
        user = r.scalar_one_or_none()

        if not user or not verify_password(req.password, user.hashed_password):
            raise UnauthorizedException("E-posta veya sifre yanlis.")

        if not user.is_active:
            raise UnauthorizedException("Hesabiniz askiya alinmistir.")

        return await self._issue_tokens(user)

    # ── US-004: Cikis ────────────────────────────────────────────────────────

    async def logout(self, refresh_token: str) -> None:
        """Refresh token'i iptal eder."""
        r = await self.db.execute(
            select(RefreshToken).where(RefreshToken.token == refresh_token)
        )
        token_obj = r.scalar_one_or_none()
        if token_obj:
            token_obj.is_revoked = True
            await self.db.flush()

    async def logout_all(self, user_id: str) -> None:
        """Kullanicinin tum refresh token'larini iptal eder (tum cihazlardan cikis)."""
        r = await self.db.execute(
            select(RefreshToken).where(
                RefreshToken.user_id == user_id,
                RefreshToken.is_revoked == False,
            )
        )
        for token_obj in r.scalars().all():
            token_obj.is_revoked = True
        await self.db.flush()

    # ── Token Yenileme ───────────────────────────────────────────────────────

    async def refresh(self, refresh_token: str) -> TokenResponse:
        """Gecerli refresh token ile yeni token cifti uretir."""
        r = await self.db.execute(
            select(RefreshToken).where(RefreshToken.token == refresh_token)
        )
        token_obj = r.scalar_one_or_none()

        if not token_obj or token_obj.is_revoked:
            raise UnauthorizedException("Gecersiz veya suresi dolmus token.")

        if token_obj.expires_at < datetime.now(timezone.utc):
            raise UnauthorizedException("Refresh token suresi dolmus. Lutfen tekrar giris yapin.")

        # Eski token'i iptal et (rotation)
        token_obj.is_revoked = True
        await self.db.flush()

        user = await self.db.get(User, token_obj.user_id)
        if not user or not user.is_active:
            raise UnauthorizedException("Kullanici bulunamadi veya askiya alindi.")

        return await self._issue_tokens(user)

    # ── US-003: Sifre Sifirlama ──────────────────────────────────────────────

    async def forgot_password(self, email: str) -> str:
        """
        Sifre sifirlama token'i uretir.
        Gercek uygulamada bu token e-posta ile gonderilir.
        Simdilik response'da donuyor (gelistirme kolayligi icin).
        """
        r = await self.db.execute(select(User).where(User.email == email))
        user = r.scalar_one_or_none()

        # Guvenlik: kullanici yoksa bile basari mesaji don (email enumeration onleme)
        if not user:
            return "KULLANICI_YOK"

        # 1 saatlik sifre sifirlama token'i
        reset_token = create_access_token(
            data={"sub": user.id, "purpose": "password_reset"},
            expires_delta=timedelta(hours=1),
        )
        return reset_token

    async def reset_password(self, token: str, new_password: str) -> None:
        """Token gecerliyse sifreyi sifirlar."""
        payload = decode_token(token)

        if not payload or payload.get("purpose") != "password_reset":
            raise UnauthorizedException("Gecersiz veya suresi dolmus sifirlama baglantisi.")

        user = await self.db.get(User, payload["sub"])
        if not user:
            raise NotFoundException("Kullanici")

        user.hashed_password = hash_password(new_password)
        # Tum refresh token'lari iptal et (sifre degisince tum oturumlar kapanir)
        await self.logout_all(user.id)
        await self.db.flush()

    # ── Me ───────────────────────────────────────────────────────────────────

    async def get_current_user_from_token(self, token: str) -> User:
        payload = decode_token(token)
        if not payload or payload.get("type") != "access":
            raise UnauthorizedException("Gecersiz token.")

        user = await self.db.get(User, payload["sub"])
        if not user or not user.is_active:
            raise UnauthorizedException("Kullanici bulunamadi.")
        return user

    # ── Yardimci ────────────────────────────────────────────────────────────

    async def _issue_tokens(self, user: User) -> TokenResponse:
        """Access + Refresh token cifti uretir ve DB'ye kaydeder."""
        access_token = create_access_token({"sub": user.id})
        refresh_token_str = create_refresh_token({"sub": user.id})

        # Refresh token'i DB'ye kaydet
        refresh_obj = RefreshToken(
            id=str(uuid.uuid4()),
            token=refresh_token_str,
            user_id=user.id,
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        )
        self.db.add(refresh_obj)
        await self.db.flush()

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token_str,
        )