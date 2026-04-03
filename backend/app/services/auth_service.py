import asyncio
from firebase_admin import auth as firebase_auth
from app.core.exceptions import UnauthorizedException


class AuthService:
    async def verify_token(self, token: str) -> dict:
        loop = asyncio.get_event_loop()
        try:
            return await loop.run_in_executor(
                None,
                lambda: firebase_auth.verify_id_token(token, check_revoked=True),
            )
        except firebase_auth.RevokedIdTokenError:
            raise UnauthorizedException("TOKEN_REVOKED", "Oturum sonlandirilmis.")
        except firebase_auth.ExpiredIdTokenError:
            raise UnauthorizedException("TOKEN_EXPIRED", "Oturum suresi dolmus.")
        except Exception:
            raise UnauthorizedException("INVALID_TOKEN", "Gecersiz kimlik bilgisi.")