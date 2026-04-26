import uuid
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.follow import Follow
from app.models.user import User
from app.schemas.article import FollowResponse
from app.core.exceptions import NotFoundException, ConflictException


class FollowService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def follow(self, follower_id: str, following_id: str) -> FollowResponse:
        """US-016: Yazar takip et."""
        if follower_id == following_id:
            raise ConflictException("Kendinizi takip edemezsiniz.")

        # Hedef kullanici var mi?
        target = await self.db.get(User, following_id)
        if not target:
            raise NotFoundException("Kullanici", following_id)

        # Zaten takip ediyor mu?
        r = await self.db.execute(
            select(Follow).where(
                Follow.follower_id == follower_id,
                Follow.following_id == following_id,
            )
        )
        existing = r.scalar_one_or_none()
        if existing:
            raise ConflictException("Bu yazari zaten takip ediyorsunuz.")

        follow = Follow(
            id=str(uuid.uuid4()),
            follower_id=follower_id,
            following_id=following_id,
        )
        self.db.add(follow)
        await self.db.flush()

        return FollowResponse(
            following_id=following_id,
            is_following=True,
            follower_count=await self._get_follower_count(following_id),
        )

    async def unfollow(self, follower_id: str, following_id: str) -> FollowResponse:
        """US-016: Takibi birak."""
        r = await self.db.execute(
            select(Follow).where(
                Follow.follower_id == follower_id,
                Follow.following_id == following_id,
            )
        )
        follow = r.scalar_one_or_none()
        if follow:
            await self.db.delete(follow)
            await self.db.flush()

        return FollowResponse(
            following_id=following_id,
            is_following=False,
            follower_count=await self._get_follower_count(following_id),
        )

    async def is_following(self, follower_id: str, following_id: str) -> bool:
        r = await self.db.execute(
            select(Follow).where(
                Follow.follower_id == follower_id,
                Follow.following_id == following_id,
            )
        )
        return r.scalar_one_or_none() is not None

    async def _get_follower_count(self, user_id: str) -> int:
        r = await self.db.execute(
            select(func.count()).where(Follow.following_id == user_id)
        )
        return r.scalar() or 0