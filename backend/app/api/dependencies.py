from typing import Annotated
from fastapi import Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.exceptions import UnauthorizedException
from app.services.auth_service import AuthService
from app.services.user_service import UserService
from app.schemas.user import UserRead

_auth_service = AuthService()
DBSession = Annotated[AsyncSession, Depends(get_db_session)]


async def get_current_user(
    authorization: Annotated[str | None, Header()] = None,
    db: DBSession = None,
) -> UserRead:
    if not authorization or not authorization.startswith("Bearer "):
        raise UnauthorizedException("MISSING_TOKEN", "Kimlik dogrulama tokeni eksik.")
    token = authorization.removeprefix("Bearer ").strip()
    decoded = await _auth_service.verify_token(token)
    svc = UserService(db)
    user = await svc.get_or_create_by_firebase_uid(
        uid=decoded["uid"], email=decoded.get("email", "")
    )
    return UserRead.model_validate(user)


CurrentUser = Annotated[UserRead, Depends(get_current_user)]