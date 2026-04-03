from fastapi import APIRouter
from app.api.dependencies import CurrentUser
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.user import UserRead

router = APIRouter()


@router.get("/me", response_model=ResponseEnvelope[UserRead])
async def get_me(current_user: CurrentUser):
    """
    Mevcut kullanicinin profilini doner.
    Flutter: Uygulama acilisinda token + kullanici dogrulamasi.
    """
    return ok(current_user)