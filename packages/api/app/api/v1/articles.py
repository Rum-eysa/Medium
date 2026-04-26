from fastapi import APIRouter, Query
from app.api.dependencies import CurrentUser, DBSession
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.article import (
    ArticleCreate, ArticleRead, ArticleUpdate,
    ArticleListItem, ClapResponse, FollowResponse,
)
from app.services.article_service import ArticleService
from app.services.clap_service import ClapService
from app.services.follow_service import FollowService
from app.core.exceptions import NotFoundException

router = APIRouter()


# ── US-006 + US-007: Olustur ──────────────────────────────────────────────────

@router.post(
    "/",
    response_model=ResponseEnvelope[ArticleRead],
    status_code=201,
    summary="US-006/007 — Taslak kaydet veya yayinla",
)
async def create_article(
    body: ArticleCreate,
    current_user: CurrentUser,
    db: DBSession,
):
    """
    status='draft'  → taslak kaydeder (US-006)
    status='published' → yayinlar (US-007)
    """
    svc = ArticleService(db)
    article = await svc.create(author_id=current_user.id, schema=body)
    return ok(ArticleRead.model_validate(article))


# ── Listeleme ─────────────────────────────────────────────────────────────────

@router.get(
    "/",
    response_model=ResponseEnvelope[list[ArticleListItem]],
    summary="Yayinlanmis makaleler",
)
async def list_articles(
    db: DBSession,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    svc = ArticleService(db)
    articles = await svc.get_published(skip=skip, limit=limit)
    return ok(
        [ArticleListItem.model_validate(a) for a in articles],
        meta={"skip": skip, "limit": limit},
    )


@router.get(
    "/my",
    response_model=ResponseEnvelope[list[ArticleListItem]],
    summary="Benim makalelerim (taslaklar dahil)",
)
async def my_articles(
    current_user: CurrentUser,
    db: DBSession,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
):
    svc = ArticleService(db)
    articles = await svc.get_by_author(
        author_id=current_user.id, include_drafts=True, skip=skip, limit=limit
    )
    return ok([ArticleListItem.model_validate(a) for a in articles])


# ── Tekil okuma ───────────────────────────────────────────────────────────────

@router.get(
    "/{article_id}",
    response_model=ResponseEnvelope[ArticleRead],
    summary="Makale detayi",
)
async def get_article(article_id: str, db: DBSession):
    svc = ArticleService(db)
    article = await svc.get_by_id(article_id)
    if not article:
        raise NotFoundException("Makale", article_id)
    await svc.increment_view(article_id)
    return ok(ArticleRead.model_validate(article))


# ── US-008: Guncelle ─────────────────────────────────────────────────────────

@router.patch(
    "/{article_id}",
    response_model=ResponseEnvelope[ArticleRead],
    summary="US-008 — Makale duzenle",
)
async def update_article(
    article_id: str,
    body: ArticleUpdate,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = ArticleService(db)
    article = await svc.update(
        article_id=article_id, author_id=current_user.id, schema=body
    )
    return ok(ArticleRead.model_validate(article))


# ── US-008: Sil ───────────────────────────────────────────────────────────────

@router.delete(
    "/{article_id}",
    response_model=ResponseEnvelope[dict],
    summary="US-008 — Makale sil",
)
async def delete_article(
    article_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = ArticleService(db)
    await svc.delete(article_id=article_id, author_id=current_user.id)
    return ok({"message": "Makale silindi."})


# ── US-014: Clap ─────────────────────────────────────────────────────────────

@router.post(
    "/{article_id}/clap",
    response_model=ResponseEnvelope[ClapResponse],
    summary="US-014 — Makaleyi begeni (Clap)",
)
async def clap_article(
    article_id: str,
    current_user: CurrentUser,
    db: DBSession,
    count: int = Query(1, ge=1, le=10, description="Bir seferde max 10 clap"),
):
    svc = ClapService(db)
    result = await svc.clap(
        user_id=current_user.id, article_id=article_id, count=count
    )
    return ok(result)


# ── US-016: Takip ─────────────────────────────────────────────────────────────

@router.post(
    "/authors/{author_id}/follow",
    response_model=ResponseEnvelope[FollowResponse],
    summary="US-016 — Yazar takip et",
)
async def follow_author(
    author_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = FollowService(db)
    result = await svc.follow(
        follower_id=current_user.id, following_id=author_id
    )
    return ok(result)


@router.delete(
    "/authors/{author_id}/follow",
    response_model=ResponseEnvelope[FollowResponse],
    summary="US-016 — Takibi birak",
)
async def unfollow_author(
    author_id: str,
    current_user: CurrentUser,
    db: DBSession,
):
    svc = FollowService(db)
    result = await svc.unfollow(
        follower_id=current_user.id, following_id=author_id
    )
    return ok(result)