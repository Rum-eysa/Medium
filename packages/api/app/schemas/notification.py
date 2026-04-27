from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime


class NotificationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    type: str
    title: str
    message: str
    is_read: bool
    created_at: datetime
    related_user_id: Optional[str] = None
    related_article_id: Optional[str] = None


class NotificationUpdate(BaseModel):
    is_read: bool