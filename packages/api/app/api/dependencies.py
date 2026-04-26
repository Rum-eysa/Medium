from typing import Annotated
from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.exceptions import UnauthorizedException
from app.services.auth_service import AuthService
from app.models.user import User

_bearer_scheme = HTTPBearer(auto_error=False)

DBSession = Annotated[AsyncSession, Depends(get_db_session)]


async def get_current_user(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None,
        Depends(_bearer_scheme)
    ] = None,
    db: DBSession = None,
) -> User:
    """Access token dogrular, User ORM nesnesi doner."""
    if not credentials or not credentials.credentials:
        raise UnauthorizedException("Authorization header eksik.")

    svc = AuthService(db)
    return await svc.get_current_user_from_token(credentials.credentials)


CurrentUser = Annotated[User, Depends(get_current_user)]