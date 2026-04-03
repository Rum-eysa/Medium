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
    """
    Firestore dokumanu -> Pydantic -> Flutter UserModel
    from_firestore() ile Firestore dict'inden olusturulur.
    """
    model_config = ConfigDict(populate_by_name=True)

    id: str                          # Firestore dokuman ID (= firebase_uid)
    firebase_uid: str
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None

    @classmethod
    def from_firestore(cls, doc_id: str, data: dict) -> "UserRead":
        """Firestore snapshot'tan UserRead olusturur."""
        return cls(
            id=doc_id,
            firebase_uid=data.get("firebase_uid", doc_id),
            email=data.get("email", ""),
            display_name=data.get("display_name"),
            photo_url=data.get("photo_url"),
            is_active=data.get("is_active", True),
            created_at=data.get("created_at", datetime.utcnow()),
            updated_at=data.get("updated_at"),
        )