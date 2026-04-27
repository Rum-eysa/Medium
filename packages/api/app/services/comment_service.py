import uuid
from typing import Optional, List
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.comment import Comment
from app.models.article import Article
from app.schemas.comment import CommentCreate
from app.core.exceptions import NotFoundException, ForbiddenException


class CommentService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, author_id: str, article_id: str, schema: CommentCreate) -> Comment:
        article = await self.db.get(Article, article_id)
        if not article:
            raise NotFoundException("Makale", article_id)

        comment = Comment(
            id=str(uuid.uuid4()),
            article_id=article_id,
            author_id=author_id,
            content=schema.content,
        )
        self.db.add(comment)
        await self.db.flush()
        return comment

    async def get_by_id(self, comment_id: str) -> Optional[Comment]:
        r = await self.db.execute(select(Comment).where(Comment.id == comment_id))
        return r.scalar_one_or_none()

    async def get_by_article(self, article_id: str, skip: int = 0, limit: int = 50) -> List[Comment]:
        r = await self.db.execute(
            select(Comment)
            .where(Comment.article_id == article_id)
            .order_by(Comment.created_at.desc())
            .offset(skip)
            .limit(limit)
            .options(selectinload(Comment.author))
        )
        return list(r.scalars().all())

    async def delete(self, comment_id: str, author_id: str) -> None:
        comment = await self.get_by_id(comment_id)
        if not comment:
            raise NotFoundException("Yorum", comment_id)
        if comment.author_id != author_id:
            raise ForbiddenException("Bu yorumu silme yetkiniz yok.")
        await self.db.delete(comment)
        await self.db.flush()