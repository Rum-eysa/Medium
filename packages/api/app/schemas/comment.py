from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class CommentCreate(BaseModel):
    content: str


class CommentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    content: str
    author_id: str
    article_id: str
    created_at: datetime
    updated_at: Optional[datetime] = None


class CommentListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    content: str
    author_id: str
    author_username: str
    created_at: datetime