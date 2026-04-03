from typing import Annotated
from fastapi import Depends, Header
from google.cloud.firestore_v1.async_client import AsyncClient

from app.core.firebase import get_firestore
from app.core.exceptions import UnauthorizedException
from app.services.auth_service import AuthService
from app.services.user_service import UserService
from app.schemas.user import UserRead

_auth_service = AuthService()

# Firestore client — her istek icin ayni instance (singleton)
FirestoreDB = Annotated[AsyncClient, Depends(get_firestore)]


async def get_current_user(
    authorization: Annotated[str | None, Header()] = None,
    db: FirestoreDB = None,
) -> UserRead:
    """
    Bearer token dogrular, Firestore'dan kullaniciyi getirir/olusturur.
    Flutter: Dio interceptor her istekte Authorization header ekler.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise UnauthorizedException("MISSING_TOKEN", "Kimlik dogrulama tokeni eksik.")

    token = authorization.removeprefix("Bearer ").strip()
    decoded = await _auth_service.verify_token(token)

    svc = UserService(db)
    return await svc.get_or_create(
        uid=decoded["uid"],
        email=decoded.get("email", ""),
    )


CurrentUser   = Annotated[UserRead, Depends(get_current_user)]