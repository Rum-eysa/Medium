from fastapi import APIRouter, Body
from app.api.dependencies import CurrentUser, DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse,
    RefreshRequest, ForgotPasswordRequest, ResetPasswordRequest,
)
from app.schemas.user import UserRead
from app.services.auth_service import AuthService

router = APIRouter()


# ── US-001: Kayit ─────────────────────────────────────────────────────────────

@router.post(
    "/register",
    response_model=ResponseEnvelope[TokenResponse],
    summary="US-001 — E-posta ile kayit",
    status_code=201,
)
async def register(body: RegisterRequest, db: DBSession):
    """
    Yeni kullanici olusturur ve token cifti doner.
    Flutter: Kayit basarili olunca dogrudan giris yapilmis sayilir.
    """
    svc = AuthService(db)
    tokens = await svc.register(body)
    return ok(tokens)


# ── US-002: Giris ──────────────────────────────────────────────────────────────

@router.post(
    "/login",
    response_model=ResponseEnvelope[TokenResponse],
    summary="US-002 — E-posta / sifre ile giris",
)
async def login(body: LoginRequest, db: DBSession):
    """
    Gecerli kimlik bilgileriyle access + refresh token doner.
    Flutter: Token'lari SecureStorage'a kaydet.
    """
    svc = AuthService(db)
    tokens = await svc.login(body)
    return ok(tokens)


# ── US-003: Sifre Sifirlama ────────────────────────────────────────────────────

@router.post(
    "/forgot-password",
    response_model=ResponseEnvelope[dict],
    summary="US-003 — Sifre sifirlama talebi",
)
async def forgot_password(body: ForgotPasswordRequest, db: DBSession):
    """
    Sifre sifirlama token'i uretir.
    Prod: Token e-posta ile gonderilir.
    Dev: Token response'da dogrudan doner (test kolayligi).
    """
    svc = AuthService(db)
    reset_token = await svc.forgot_password(body.email)

    # Guvenlik: kullanici yoksa da ayni mesaji don
    if reset_token == "KULLANICI_YOK":
        return ok({"message": "E-posta adresinize sifirlama baglantisi gonderildi."})

    return ok({
        "message": "E-posta adresinize sifirlama baglantisi gonderildi.",
        "dev_token": reset_token,  # SADECE DEBUG modunda; prod'da kaldir
    })


@router.post(
    "/reset-password",
    response_model=ResponseEnvelope[dict],
    summary="US-003 — Yeni sifre belirleme",
)
async def reset_password(body: ResetPasswordRequest, db: DBSession):
    svc = AuthService(db)
    await svc.reset_password(body.token, body.new_password)
    return ok({"message": "Sifreniz basariyla guncellendi. Lutfen yeniden giris yapin."})


# ── US-004: Cikis ──────────────────────────────────────────────────────────────

@router.post(
    "/logout",
    response_model=ResponseEnvelope[dict],
    summary="US-004 — Cikis yap",
)
async def logout(body: RefreshRequest, db: DBSession):
    """Refresh token'i iptal eder (tek cihaz cikis)."""
    svc = AuthService(db)
    await svc.logout(body.refresh_token)
    return ok({"message": "Cikis basarili."})


@router.post(
    "/logout-all",
    response_model=ResponseEnvelope[dict],
    summary="US-004 — Tum cihazlardan cikis",
)
async def logout_all(current_user: CurrentUser, db: DBSession):
    """Tum aktif refresh token'lari iptal eder."""
    svc = AuthService(db)
    await svc.logout_all(current_user.id)
    return ok({"message": "Tum cihazlardan cikis yapildi."})


# ── Token Yenileme ─────────────────────────────────────────────────────────────

@router.post(
    "/refresh",
    response_model=ResponseEnvelope[TokenResponse],
    summary="Access token yenile",
)
async def refresh_token(body: RefreshRequest, db: DBSession):
    """
    Gecerli refresh token ile yeni token cifti uretir.
    Flutter: Access token suresi dolunca bu endpoint cagirilir.
    """
    svc = AuthService(db)
    tokens = await svc.refresh(body.refresh_token)
    return ok(tokens)


# ── Mevcut Kullanici ───────────────────────────────────────────────────────────

@router.get(
    "/me",
    response_model=ResponseEnvelope[UserRead],
    summary="Mevcut kullanici bilgisi",
)
async def get_me(current_user: CurrentUser):
    return ok(UserRead.model_validate(current_user))