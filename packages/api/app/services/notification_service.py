import uuid
from typing import Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification
from app.core.exceptions import NotFoundException


class NotificationService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(
        self,
        user_id: str,
        notif_type: str,
        title: str,
        message: str,
        related_user_id: Optional[str] = None,
        related_article_id: Optional[str] = None,
    ) -> Notification:
        notification = Notification(
            id=str(uuid.uuid4()),
            user_id=user_id,
            type=notif_type,
            title=title,
            message=message,
            related_user_id=related_user_id,
            related_article_id=related_article_id,
        )
        self.db.add(notification)
        await self.db.flush()
        return notification

    async def get_user_notifications(
        self, user_id: str, skip: int = 0, limit: int = 20, unread_only: bool = False
    ) -> List[Notification]:
        q = select(Notification).where(Notification.user_id == user_id)
        if unread_only:
            q = q.where(Notification.is_read == False)
        q = q.order_by(Notification.created_at.desc()).offset(skip).limit(limit)
        r = await self.db.execute(q)
        return list(r.scalars().all())

    async def mark_as_read(self, notification_id: str) -> Optional[Notification]:
        notification = await self.db.get(Notification, notification_id)
        if notification:
            notification.is_read = True
            await self.db.flush()
        return notification

    async def mark_all_as_read(self, user_id: str) -> None:
        r = await self.db.execute(
            select(Notification).where(
                Notification.user_id == user_id,
                Notification.is_read == False,
            )
        )
        for notif in r.scalars().all():
            notif.is_read = True
        await self.db.flush()