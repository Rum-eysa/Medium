import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.clap import Clap
from app.models.article import Article
from app.schemas.article import ClapResponse
from app.core.exceptions import NotFoundException


class ClapService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def clap(self, user_id: str, article_id: str) -> ClapResponse:
        """US-014: Kullanici makaleyi bir kez alkislar; tekrar basarsa geri alir."""
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
            await self.db.delete(clap)
            article.clap_count = max(article.clap_count - 1, 0)
            user_clap_count = 0
            is_clapped = False
        else:
            clap = Clap(
                id=str(uuid.uuid4()),
                user_id=user_id,
                article_id=article_id,
                count=1,
            )
            self.db.add(clap)
            article.clap_count += 1
            user_clap_count = 1
            is_clapped = True

        await self.db.flush()

        return ClapResponse(
            article_id=article_id,
            total_claps=article.clap_count,
            user_clap_count=user_clap_count,
            is_clapped=is_clapped,
        )

    async def get_user_clap(self, user_id: str, article_id: str) -> int:
        r = await self.db.execute(
            select(Clap).where(Clap.user_id == user_id, Clap.article_id == article_id)
        )
        clap = r.scalar_one_or_none()
        return clap.count if clap else 0
