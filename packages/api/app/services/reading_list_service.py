import uuid
from typing import Optional, List
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.reading_list import ReadingList
from app.models.article import Article
from app.core.exceptions import ConflictException, NotFoundException


class ReadingListService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def add(self, user_id: str, article_id: str) -> bool:
        article = await self.db.get(Article, article_id)
        if not article:
            raise NotFoundException("Makale", article_id)

        r = await self.db.execute(
            select(ReadingList).where(
                ReadingList.user_id == user_id,
                ReadingList.article_id == article_id,
            )
        )
        if r.scalar_one_or_none():
            raise ConflictException("Bu makale zaten okuma listesinde var.")

        reading_list = ReadingList(
            id=str(uuid.uuid4()),
            user_id=user_id,
            article_id=article_id,
        )
        self.db.add(reading_list)
        await self.db.flush()
        return True

    async def remove(self, user_id: str, article_id: str) -> bool:
        r = await self.db.execute(
            select(ReadingList).where(
                ReadingList.user_id == user_id,
                ReadingList.article_id == article_id,
            )
        )
        reading_list = r.scalar_one_or_none()
        if reading_list:
            await self.db.delete(reading_list)
            await self.db.flush()
            return True
        return False

    async def get_user_list(self, user_id: str, skip: int = 0, limit: int = 20) -> List[Article]:
        r = await self.db.execute(
            select(Article)
            .join(ReadingList, ReadingList.article_id == Article.id)
            .where(ReadingList.user_id == user_id)
            .order_by(ReadingList.created_at.desc())
            .offset(skip)
            .limit(limit)
            .options(selectinload(Article.author), selectinload(Article.tags))
        )
        return list(r.scalars().all())

    async def is_in_list(self, user_id: str, article_id: str) -> bool:
        r = await self.db.execute(
            select(ReadingList).where(
                ReadingList.user_id == user_id,
                ReadingList.article_id == article_id,
            )
        )
        return r.scalar_one_or_none() is not None