from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class UserCreate(UserBase):
    firebase_uid: str


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class UserRead(UserBase):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)
    id: str
    firebase_uid: str
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None