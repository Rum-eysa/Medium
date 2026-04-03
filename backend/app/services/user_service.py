from typing import Optional, List
from datetime import datetime, timezone

from google.cloud.firestore_v1.async_client import AsyncClient

from app.services.base import BaseCRUDService
from app.schemas.user import UserCreate, UserRead, UserUpdate
from app.core.config import settings
from app.core.exceptions import NotFoundException


class UserService(BaseCRUDService):
    """
    Firestore uzerinde async kullanici CRUD islemleri.
    Koleksiyon adi .env'deki FIRESTORE_USERS_COLLECTION ile belirlenir.
    """

    def __init__(self, db: AsyncClient):
        self._col = db.collection(settings.FIRESTORE_USERS_COLLECTION)

    # ── Okuma ────────────────────────────────────────────────────────────────

    async def get_by_id(self, id: str) -> Optional[UserRead]:
        doc = await self._col.document(id).get()
        if not doc.exists:
            return None
        return UserRead.from_firestore(doc.id, doc.to_dict())

    async def get_by_firebase_uid(self, uid: str) -> Optional[UserRead]:
        """Dokuman ID'si firebase_uid ile esit — direkt fetch."""
        return await self.get_by_id(uid)

    async def get_all(self, limit: int = 20) -> List[UserRead]:
        docs = self._col.limit(limit).stream()
        return [
            UserRead.from_firestore(doc.id, doc.to_dict())
            async for doc in docs
        ]

    # ── Yazma ────────────────────────────────────────────────────────────────

    async def create(self, schema: UserCreate) -> UserRead:
        """Dokuman ID = firebase_uid (ek sorgu gerektirmez)."""
        now = datetime.now(timezone.utc)
        data = {
            "firebase_uid": schema.firebase_uid,
            "email": schema.email,
            "display_name": schema.display_name,
            "photo_url": schema.photo_url,
            "is_active": True,
            "created_at": now,
            "updated_at": None,
        }
        await self._col.document(schema.firebase_uid).set(data)
        return UserRead.from_firestore(schema.firebase_uid, data)

    async def update(self, id: str, schema: UserUpdate) -> Optional[UserRead]:
        ref = self._col.document(id)
        doc = await ref.get()
        if not doc.exists:
            raise NotFoundException("Kullanici", id)
        updates = {
            k: v for k, v in schema.model_dump(exclude_none=True).items()
        }
        updates["updated_at"] = datetime.now(timezone.utc)
        await ref.update(updates)
        updated = await ref.get()
        return UserRead.from_firestore(updated.id, updated.to_dict())

    async def delete(self, id: str) -> bool:
        ref = self._col.document(id)
        doc = await ref.get()
        if not doc.exists:
            return False
        await ref.delete()
        return True

    # ── Yardimci ─────────────────────────────────────────────────────────────

    async def get_or_create(self, uid: str, email: str) -> UserRead:
        """Token dogrulamasinin hemen ardindan kullaniciyi getir veya olustur."""
        user = await self.get_by_firebase_uid(uid)
        if not user:
            user = await self.create(UserCreate(firebase_uid=uid, email=email))
        return user