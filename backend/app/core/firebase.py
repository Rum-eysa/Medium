import firebase_admin
from firebase_admin import credentials, firestore_async
from app.core.config import settings

# Uygulama yasam dongusu boyunca tek instance
_db = None


def initialize_firebase() -> None:
    """Firebase Admin SDK baslatir. Lifespan icinde bir kez cagrilir."""
    global _db
    if firebase_admin._apps:
        return
    cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred, {
        "projectId": settings.FIREBASE_PROJECT_ID,
    })
    _db = firestore_async.client()


def get_firestore():
    """
    Async Firestore client'i doner.
    FastAPI Depends() ile kullanilir:
        db: Annotated[AsyncClient, Depends(get_firestore)]
    """
    global _db
    if _db is None:
        _db = firestore_async.client()
    return _db