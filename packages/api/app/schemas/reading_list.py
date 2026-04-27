from pydantic import BaseModel, ConfigDict
from typing import Optional


class ReadingListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    article_id: str
    user_id: str


class ReadingListResponse(BaseModel):
    article_id: str
    added: bool