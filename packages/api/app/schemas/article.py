from pydantic import BaseModel, ConfigDict, field_validator
from typing import Optional, List
from datetime import datetime
from app.models.article import ArticleStatus


class TagRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    name: str
    slug: str


class ArticleAuthor(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    username: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class ArticleCreate(BaseModel):
    title: str
    subtitle: Optional[str] = None
    content: str
    cover_image_url: Optional[str] = None
    tag_names: List[str] = []
    status: ArticleStatus = ArticleStatus.DRAFT

    @field_validator("title")
    @classmethod
    def validate_title(cls, v: str) -> str:
        v = v.strip()
        if len(v) < 10:
            raise ValueError("Baslik en az 10 karakter olmalidir.")
        if len(v) > 200:
            raise ValueError("Baslik en fazla 200 karakter olmalidir.")
        return v

    @field_validator("tag_names")
    @classmethod
    def validate_tags(cls, v: List[str]) -> List[str]:
        if len(v) > 5:
            raise ValueError("En fazla 5 etiket secebilirsiniz.")
        return [t.strip().lower() for t in v if t.strip()]


class ArticleUpdate(BaseModel):
    title: Optional[str] = None
    subtitle: Optional[str] = None
    content: Optional[str] = None
    cover_image_url: Optional[str] = None
    tag_names: Optional[List[str]] = None
    status: Optional[ArticleStatus] = None


class ArticleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    subtitle: Optional[str] = None
    content: str
    cover_image_url: Optional[str] = None
    slug: Optional[str] = None
    status: ArticleStatus
    reading_time_minutes: int
    view_count: int
    clap_count: int
    author: ArticleAuthor
    tags: List[TagRead] = []
    created_at: datetime
    updated_at: Optional[datetime] = None
    published_at: Optional[datetime] = None


class ArticleListItem(BaseModel):
    """Liste gorunumu icin ozet — content yok, daha hafif."""
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    subtitle: Optional[str] = None
    cover_image_url: Optional[str] = None
    slug: Optional[str] = None
    status: ArticleStatus
    reading_time_minutes: int
    clap_count: int
    view_count: int
    author: ArticleAuthor
    tags: List[TagRead] = []
    published_at: Optional[datetime] = None
    created_at: datetime


class ClapResponse(BaseModel):
    article_id: str
    total_claps: int
    user_clap_count: int
    is_clapped: bool


class FollowResponse(BaseModel):
    following_id: str
    is_following: bool
    follower_count: int
