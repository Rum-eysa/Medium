from pydantic import BaseModel, EmailStr, ConfigDict, field_validator
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    username: str
    display_name: Optional[str] = None


class UserCreate(UserBase):
    password: str

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Sifre en az 8 karakter olmalidir.")
        if not any(c.isupper() for c in v):
            raise ValueError("Sifre en az 1 buyuk harf icermelidir.")
        if not any(c.isdigit() for c in v):
            raise ValueError("Sifre en az 1 rakam icermelidir.")
        return v

    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        if len(v) < 3:
            raise ValueError("Kullanici adi en az 3 karakter olmalidir.")
        if not v.replace("_", "").replace("-", "").isalnum():
            raise ValueError("Kullanici adi yalnizca harf, rakam, _ ve - icerebilir.")
        return v.lower()


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    bio: Optional[str] = None
    photo_url: Optional[str] = None


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str
    username: str
    display_name: Optional[str] = None
    bio: Optional[str] = None
    photo_url: Optional[str] = None
    is_active: bool
    is_verified: bool
    created_at: datetime