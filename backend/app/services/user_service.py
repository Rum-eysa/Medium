import uuid
from typing import Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.base import BaseService
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.exceptions import NotFoundException


class UserService(BaseService[User, UserCreate, UserUpdate]):

    def __init__(self, db: AsyncSession):
        super().__init__(db)

    async def get_by_id(self, id: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.id == id))
        return r.scalar_one_or_none()

    async def get_by_firebase_uid(self, uid: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.firebase_uid == uid))
        return r.scalar_one_or_none()

    async def get_all(self, skip: int = 0, limit: int = 20) -> List[User]:
        r = await self.db.execute(select(User).offset(skip).limit(limit))
        return list(r.scalars().all())

    async def create(self, schema: UserCreate) -> User:
        user = User(
            id=str(uuid.uuid4()),
            firebase_uid=schema.firebase_uid,
            email=schema.email,
            display_name=schema.display_name,
            photo_url=schema.photo_url,
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

    async def get_or_create_by_firebase_uid(self, uid: str, email: str) -> User:
        user = await self.get_by_firebase_uid(uid)
        if not user:
            user = await self.create(UserCreate(firebase_uid=uid, email=email))
        return user