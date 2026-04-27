from fastapi import APIRouter, Query
from app.api.dependencies import CurrentUser, DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.reading_list import ReadingListResponse
from app.schemas.article import ArticleListItem
from app.services.reading_list_service import ReadingListService

router = APIRouter()


@router.post(
    "/{article_id}",
    response_model=ResponseEnvelope[ReadingListResponse],
    status_code=201,
    summary="US-018 — Okuma listesine ekle",
)
async def add_to_reading_list(
    article_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = ReadingListService(db)
    await svc.add(current_user.id, article_id)
    return ok(ReadingListResponse(article_id=article_id, added=True))


@router.delete(
    "/{article_id}",
    response_model=ResponseEnvelope[ReadingListResponse],
    summary="Okuma listesinden kaldır",
)
async def remove_from_reading_list(
    article_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = ReadingListService(db)
    await svc.remove(current_user.id, article_id)
    return ok(ReadingListResponse(article_id=article_id, added=False))


@router.get(
    "/",
    response_model=ResponseEnvelope[list[ArticleListItem]],
    summary="US-018 — Okuma listesi",
)
async def get_reading_list(
    current_user: CurrentUser,
    db: DBSession,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=50),
):
    svc = ReadingListService(db)
    articles = await svc.get_user_list(current_user.id, skip=skip, limit=limit)
    return ok([ArticleListItem.model_validate(a) for a in articles])