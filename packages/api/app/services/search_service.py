from typing import List
from sqlalchemy import select, or_
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.article import Article, ArticleStatus


class SearchService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def search(self, query: str, skip: int = 0, limit: int = 20) -> List[Article]:
        """Title, subtitle, content'te search"""
        search_query = f"%{query}%"
        r = await self.db.execute(
            select(Article)
            .where(
                Article.status == ArticleStatus.PUBLISHED,
                or_(
                    Article.title.ilike(search_query),
                    Article.subtitle.ilike(search_query),
                    Article.content.ilike(search_query),
                ),
            )
            .order_by(Article.published_at.desc())
            .offset(skip)
            .limit(limit)
            .options(selectinload(Article.author), selectinload(Article.tags))
        )
        return list(r.scalars().all())