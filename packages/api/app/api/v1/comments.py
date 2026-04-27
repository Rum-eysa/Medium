from fastapi import APIRouter, Query
from app.api.dependencies import CurrentUser, DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.comment import CommentCreate, CommentRead
from app.services.comment_service import CommentService
from app.core.exceptions import NotFoundException

router = APIRouter()


@router.post(
    "/{article_id}/comments",
    response_model=ResponseEnvelope[CommentRead],
    status_code=201,
    summary="US-015 — Yorum yaz",
)
async def create_comment(
    article_id: str,
    body: CommentCreate,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = CommentService(db)
    comment = await svc.create(
        author_id=current_user.id,
        article_id=article_id,
        schema=body,
    )
    return ok(CommentRead.model_validate(comment))


@router.get(
    "/{article_id}/comments",
    response_model=ResponseEnvelope[list[CommentRead]],
    summary="US-015 — Yorum listesi",
)
async def get_comments(
    article_id: str,
    db: DBSession,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=50),
):
    svc = CommentService(db)
    comments = await svc.get_by_article(article_id, skip=skip, limit=limit)
    return ok(
        [CommentRead.model_validate(c) for c in comments],
        meta={"skip": skip, "limit": limit},
    )


@router.delete(
    "/comments/{comment_id}",
    response_model=ResponseEnvelope[dict],
    summary="Yorum sil",
)
async def delete_comment(
    comment_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = CommentService(db)
    await svc.delete(comment_id, author_id=current_user.id)
    return ok({"message": "Yorum silindi."})