import uuid
import re
from typing import Optional, List
from datetime import datetime, timezone

from sqlalchemy import select, func, and_
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.article import Article, ArticleStatus
from app.models.tag import Tag
from app.models.article_tag import ArticleTag
from app.schemas.article import ArticleCreate, ArticleUpdate
from app.core.exceptions import NotFoundException, ForbiddenException


def _calculate_reading_time(content: str) -> int:
    """Ortalama 200 kelime/dakika hesaplamasiyla okuma suresi."""
    word_count = len(content.split())
    minutes = max(1, round(word_count / 200))
    return minutes


def _generate_slug(title: str, article_id: str) -> str:
    """Basliktan URL-dostu slug olusturur."""
    slug = title.lower().strip()
    slug = re.sub(r"[^\w\s-]", "", slug)
    slug = re.sub(r"[\s_-]+", "-", slug)
    slug = slug.strip("-")
    # Benzersizlik icin ID'nin ilk 8 karakterini ekle
    return f"{slug}-{article_id[:8]}"


async def _get_or_create_tags(db: AsyncSession, tag_names: List[str]) -> List[Tag]:
    """Etiketleri getirir, yoksa olusturur."""
    tags = []
    for name in tag_names:
        slug = re.sub(r"[^\w\s-]", "", name.lower())
        slug = re.sub(r"[\s_-]+", "-", slug).strip("-")

        r = await db.execute(select(Tag).where(Tag.slug == slug))
        tag = r.scalar_one_or_none()
        if not tag:
            tag = Tag(id=str(uuid.uuid4()), name=name, slug=slug)
            db.add(tag)
            await db.flush()
        tags.append(tag)
    return tags


class ArticleService:

    def __init__(self, db: AsyncSession):
        self.db = db

    # ── US-006 + US-007: Olustur (Taslak veya Yayinla) ──────────────────────

    async def create(self, author_id: str, schema: ArticleCreate) -> Article:
        article_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc)

        article = Article(
            id=article_id,
            author_id=author_id,
            title=schema.title,
            subtitle=schema.subtitle,
            content=schema.content,
            cover_image_url=schema.cover_image_url,
            status=schema.status,
            reading_time_minutes=_calculate_reading_time(schema.content),
            slug=_generate_slug(schema.title, article_id) if schema.status == ArticleStatus.PUBLISHED else None,
            published_at=now if schema.status == ArticleStatus.PUBLISHED else None,
        )
        self.db.add(article)
        await self.db.flush()

        # Etiketleri isle
        if schema.tag_names:
            tags = await _get_or_create_tags(self.db, schema.tag_names)
            for tag in tags:
                self.db.add(ArticleTag(article_id=article.id, tag_id=tag.id))
            await self.db.flush()

        # Iliskileri yukle
        return await self._get_with_relations(article.id)

    # ── US-008: Guncelle ─────────────────────────────────────────────────────

    async def update(self, article_id: str, author_id: str, schema: ArticleUpdate) -> Article:
        article = await self._get_with_relations(article_id)
        if not article:
            raise NotFoundException("Makale", article_id)
        if article.author_id != author_id:
            raise ForbiddenException("Bu makaleyi duzenleme yetkiniz yok.")

        if schema.title is not None:
            article.title = schema.title
        if schema.subtitle is not None:
            article.subtitle = schema.subtitle
        if schema.content is not None:
            article.content = schema.content
            article.reading_time_minutes = _calculate_reading_time(schema.content)
        if schema.cover_image_url is not None:
            article.cover_image_url = schema.cover_image_url

        # Yayinlama durumu degistiyse
        if schema.status is not None and schema.status != article.status:
            article.status = schema.status
            if schema.status == ArticleStatus.PUBLISHED and not article.published_at:
                article.published_at = datetime.now(timezone.utc)
                article.slug = _generate_slug(article.title, article.id)

        # Etiketleri guncelle
        if schema.tag_names is not None:
            await self.db.execute(
                ArticleTag.__table__.delete().where(ArticleTag.article_id == article_id)
            )
            await self.db.flush()
            if schema.tag_names:
                tags = await _get_or_create_tags(self.db, schema.tag_names)
                for tag in tags:
                    self.db.add(ArticleTag(article_id=article.id, tag_id=tag.id))
                await self.db.flush()

        return await self._get_with_relations(article_id)

    # ── US-008: Sil ──────────────────────────────────────────────────────────

    async def delete(self, article_id: str, author_id: str) -> None:
        article = await self._get_by_id(article_id)
        if not article:
            raise NotFoundException("Makale", article_id)
        if article.author_id != author_id:
            raise ForbiddenException("Bu makaleyi silme yetkiniz yok.")
        await self.db.delete(article)
        await self.db.flush()

    # ── Okuma ────────────────────────────────────────────────────────────────

    async def get_by_id(self, article_id: str) -> Optional[Article]:
        return await self._get_with_relations(article_id)

    async def get_by_slug(self, slug: str) -> Optional[Article]:
        r = await self.db.execute(
            select(Article)
            .where(Article.slug == slug)
            .options(
                selectinload(Article.author),
                selectinload(Article.tags),
            )
        )
        return r.scalar_one_or_none()

    async def get_published(self, skip: int = 0, limit: int = 20) -> List[Article]:
        r = await self.db.execute(
            select(Article)
            .where(Article.status == ArticleStatus.PUBLISHED)
            .order_by(Article.published_at.desc())
            .offset(skip)
            .limit(limit)
            .options(
                selectinload(Article.author),
                selectinload(Article.tags),
            )
        )
        return list(r.scalars().all())

    async def get_by_author(
        self, author_id: str, include_drafts: bool = False, skip: int = 0, limit: int = 20
    ) -> List[Article]:
        q = select(Article).where(Article.author_id == author_id)
        if not include_drafts:
            q = q.where(Article.status == ArticleStatus.PUBLISHED)
        q = q.order_by(Article.created_at.desc()).offset(skip).limit(limit)
        q = q.options(selectinload(Article.author), selectinload(Article.tags))
        r = await self.db.execute(q)
        return list(r.scalars().all())

    async def increment_view(self, article_id: str) -> None:
        article = await self._get_by_id(article_id)
        if article:
            article.view_count += 1
            await self.db.flush()

    # ── Yardimcilar ──────────────────────────────────────────────────────────

    async def _get_by_id(self, article_id: str) -> Optional[Article]:
        r = await self.db.execute(select(Article).where(Article.id == article_id))
        return r.scalar_one_or_none()

    async def _get_with_relations(self, article_id: str) -> Optional[Article]:
        r = await self.db.execute(
            select(Article)
            .where(Article.id == article_id)
            .options(
                selectinload(Article.author),
                selectinload(Article.tags),
            )
        )
        return r.scalar_one_or_none()