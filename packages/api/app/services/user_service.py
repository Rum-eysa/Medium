import uuid
from typing import Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.base import BaseService
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.exceptions import NotFoundException, ConflictException
from app.core.security import hash_password


class UserService(BaseService[User, UserCreate, UserUpdate]):

    def __init__(self, db: AsyncSession):
        super().__init__(db)

    async def get_by_id(self, id: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.id == id))
        return r.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.email == email))
        return r.scalar_one_or_none()

    async def get_by_username(self, username: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.username == username))
        return r.scalar_one_or_none()

    async def get_all(self, skip: int = 0, limit: int = 20) -> List[User]:
        r = await self.db.execute(select(User).offset(skip).limit(limit))
        return list(r.scalars().all())

    async def create(self, schema: UserCreate) -> User:
        # Duplicate kontrol
        if await self.get_by_email(schema.email):
            raise ConflictException("Bu e-posta adresi zaten kayitli.")
        if await self.get_by_username(schema.username):
            raise ConflictException("Bu kullanici adi zaten alinmis.")

        user = User(
            id=str(uuid.uuid4()),
            email=schema.email,
            username=schema.username.lower(),
            hashed_password=hash_password(schema.password),
            display_name=schema.display_name or schema.username,
        )
        self.db.add(user)
        await self.db.flush()
        return user

    async def update(self, id: str, schema: UserUpdate) -> Optional[User]:
        user = await self.get_by_id(id)
        if not user:
            raise NotFoundException("Kullanici", id)
        for field, value in schema.model_dump(exclude_none=True).items():
            setattr(user, field, value)
        await self.db.flush()
        return user

    async def delete(self, id: str) -> bool:
        user = await self.get_by_id(id)
        if not user:
            return False
        await self.db.delete(user)
        return True