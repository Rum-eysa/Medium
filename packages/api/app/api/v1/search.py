from fastapi import APIRouter, Query
from app.api.dependencies import DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.article import ArticleListItem
from app.services.search_service import SearchService

router = APIRouter()


@router.get(
    "/",
    response_model=ResponseEnvelope[list[ArticleListItem]],
    summary="US-012 — Arama",
)
async def search_articles(
    q: str = Query(..., min_length=2),
    db: DBSession = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=50),
):
    svc = SearchService(db)
    articles = await svc.search(q, skip=skip, limit=limit)
    return ok(
        [ArticleListItem.model_validate(a) for a in articles],
        meta={"query": q, "skip": skip, "limit": limit},
    )