from sqlalchemy import String, Integer, Float, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from datetime import datetime
from app.core.database import Base


class AuthorStats(Base):
    __tablename__ = "author_stats"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    author_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True, index=True
    )
    total_articles: Mapped[int] = mapped_column(Integer, default=0)
    total_views: Mapped[int] = mapped_column(Integer, default=0)
    total_claps: Mapped[int] = mapped_column(Integer, default=0)
    total_followers: Mapped[int] = mapped_column(Integer, default=0)
    average_reading_time: Mapped[float] = mapped_column(Float, default=0.0)
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), onupdate=func.now(), nullable=True
    )