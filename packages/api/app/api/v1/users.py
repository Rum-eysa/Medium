from fastapi import APIRouter
from app.api.dependencies import CurrentUser, DBSession
from app.services.user_service import UserService
from app.services.article_service import ArticleService
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.user import UserRead, UserUpdate
from app.schemas.article import ArticleListItem
from app.core.exceptions import NotFoundException

router = APIRouter()


@router.get("/me", response_model=ResponseEnvelope[UserRead])
async def get_my_profile(current_user: CurrentUser):
    return ok(UserRead.model_validate(current_user))


@router.patch(
    "/me",
    response_model=ResponseEnvelope[UserRead],
    summary="US-020 — Profil duzenle",
)
async def update_my_profile(
    body: UserUpdate,
    current_user: CurrentUser,
    db: DBSession,
):
    """
    display_name, bio, photo_url guncellenir.
    US-020 Profil Duzenleme.
    """
    svc = UserService(db)
    user = await svc.update(current_user.id, body)
    return ok(UserRead.model_validate(user))


@router.get("/{username}", response_model=ResponseEnvelope[UserRead])
async def get_user_profile(username: str, db: DBSession):
    svc = UserService(db)
    user = await svc.get_by_username(username)
    if not user:
        raise NotFoundException("Kullanici", username)
    return ok(UserRead.model_validate(user))


@router.get(
    "/{username}/articles",
    response_model=ResponseEnvelope[list[ArticleListItem]],
    summary="Yazarin makaleleri",
)
async def get_user_articles(username: str, db: DBSession):
    user_svc = UserService(db)
    user = await user_svc.get_by_username(username)
    if not user:
        raise NotFoundException("Kullanici", username)

    article_svc = ArticleService(db)
    articles = await article_svc.get_by_author(author_id=user.id)
    return ok([ArticleListItem.model_validate(a) for a in articles])