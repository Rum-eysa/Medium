from fastapi import APIRouter
from app.api.dependencies import CurrentUser, FirestoreDB
from app.services.user_service import UserService
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.user import UserRead, UserUpdate
from app.core.exceptions import NotFoundException

router = APIRouter()


@router.get("/", response_model=ResponseEnvelope[list[UserRead]])
async def list_users(current_user: CurrentUser, db: FirestoreDB,
                     limit: int = 20):
    svc = UserService(db)
    users = await svc.get_all(limit=limit)
    return ok(users, meta={"count": len(users)})


@router.get("/{user_id}", response_model=ResponseEnvelope[UserRead])
async def get_user(user_id: str, current_user: CurrentUser, db: FirestoreDB):
    svc = UserService(db)
    user = await svc.get_by_id(user_id)
    if not user:
        raise NotFoundException("Kullanici", user_id)
    return ok(user)


@router.patch("/{user_id}", response_model=ResponseEnvelope[UserRead])
async def update_user(user_id: str, body: UserUpdate,
                      current_user: CurrentUser, db: FirestoreDB):
    svc = UserService(db)
    user = await svc.update(user_id, body)
    return ok(user)


@router.delete("/{user_id}", response_model=ResponseEnvelope[None])
async def delete_user(user_id: str, current_user: CurrentUser, db: FirestoreDB):
    svc = UserService(db)
    if not await svc.delete(user_id):
        raise NotFoundException("Kullanici", user_id)
    return ok(None)