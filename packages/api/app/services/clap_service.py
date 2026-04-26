import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.clap import Clap
from app.models.article import Article
from app.schemas.article import ClapResponse
from app.core.exceptions import NotFoundException

MAX_CLAPS_PER_USER = 50


class ClapService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def clap(self, user_id: str, article_id: str, count: int = 1) -> ClapResponse:
        """US-014: Makaleye clap ekle (max 50/kullanici)."""
        # Makale var mi?
        article = await self.db.get(Article, article_id)
        if not article:
            raise NotFoundException("Makale", article_id)

        # Mevcut clap kaydini kontrol et
        r = await self.db.execute(
            select(Clap).where(
                Clap.user_id == user_id,
                Clap.article_id == article_id,
            )
        )
        clap = r.scalar_one_or_none()

        if clap:
            # Mevcut kaydi guncelle (max 50)
            new_count = min(clap.count + count, MAX_CLAPS_PER_USER)
            added = new_count - clap.count
            clap.count = new_count
        else:
            # Yeni kayit olustur
            added = min(count, MAX_CLAPS_PER_USER)
            clap = Clap(
                id=str(uuid.uuid4()),
                user_id=user_id,
                article_id=article_id,
                count=added,
            )
            self.db.add(clap)

        # Makale toplam clap sayisini guncelle
        article.clap_count += added
        await self.db.flush()

        return ClapResponse(
            article_id=article_id,
            total_claps=article.clap_count,
            user_clap_count=clap.count,
        )

    async def get_user_clap(self, user_id: str, article_id: str) -> int:
        r = await self.db.execute(
            select(Clap).where(Clap.user_id == user_id, Clap.article_id == article_id)
        )
        clap = r.scalar_one_or_none()
        return clap.count if clap else 0