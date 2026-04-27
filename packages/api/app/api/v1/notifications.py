from fastapi import APIRouter, Query
from app.api.dependencies import CurrentUser, DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.notification import NotificationRead, NotificationUpdate
from app.services.notification_service import NotificationService

router = APIRouter()


@router.get(
    "/",
    response_model=ResponseEnvelope[list[NotificationRead]],
    summary="US-017 — Bildirim merkezi",
)
async def get_notifications(
    current_user: CurrentUser,
    db: DBSession,
    unread_only: bool = Query(False),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=50),
):
    svc = NotificationService(db)
    notifications = await svc.get_user_notifications(
        current_user.id, unread_only=unread_only, skip=skip, limit=limit
    )
    return ok([NotificationRead.model_validate(n) for n in notifications])


@router.patch(
    "/{notification_id}",
    response_model=ResponseEnvelope[NotificationRead],
    summary="Bildirimi oku olarak işaretle",
)
async def mark_as_read(
    notification_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = NotificationService(db)
    notification = await svc.mark_as_read(notification_id)
    return ok(NotificationRead.model_validate(notification))


@router.post(
    "/mark-all-read",
    response_model=ResponseEnvelope[dict],
    summary="Tüm bildirimleri oku olarak işaretle",
)
async def mark_all_as_read(
    current_user: CurrentUser,
    db: DBSession,
):
    svc = NotificationService(db)
    await svc.mark_all_as_read(current_user.id)
    return ok({"message": "Tüm bildirimler okundu olarak işaretlendi."})