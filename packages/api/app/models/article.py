from sqlalchemy import String, Boolean, DateTime, Text, Integer, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from datetime import datetime
import enum
from app.core.database import Base


class ArticleStatus(str, enum.Enum):
    DRAFT     = "draft"
    PUBLISHED = "published"
    ARCHIVED  = "archived"


class Article(Base):
    __tablename__ = "articles"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    author_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )

    # Icerik
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    subtitle: Mapped[str | None] = mapped_column(String(300), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)          # Rich text (HTML/Markdown)
    cover_image_url: Mapped[str | None] = mapped_column(String(1024), nullable=True)

    # Yayinlama
    status: Mapped[ArticleStatus] = mapped_column(
        Enum(ArticleStatus), default=ArticleStatus.DRAFT, nullable=False, index=True
    )
    slug: Mapped[str | None] = mapped_column(String(250), unique=True, nullable=True, index=True)
    reading_time_minutes: Mapped[int] = mapped_column(Integer, default=1)

    # Istatistik
    view_count: Mapped[int] = mapped_column(Integer, default=0)
    clap_count: Mapped[int] = mapped_column(Integer, default=0)

    # Zaman
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), onupdate=func.now(), nullable=True
    )
    published_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Iliskiler
    author: Mapped["User"] = relationship("User", back_populates="articles")
    tags: Mapped[list["Tag"]] = relationship(
        secondary="article_tags", back_populates="articles"
    )
    claps: Mapped[list["Clap"]] = relationship(
        back_populates="article", cascade="all, delete-orphan"
    )