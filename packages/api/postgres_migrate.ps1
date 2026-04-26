# =============================================================================
# postgres_migrate.ps1
# Firestore -> PostgreSQL gecisi + 3 servisli Docker Compose
# Kullanim: .\postgres_migrate.ps1
# =============================================================================

param([string]$ProjectName = "projem")

$ErrorActionPreference = "Stop"

function Log  { param($m) Write-Host "  [OK] $m" -ForegroundColor Green  }
function Info { param($m) Write-Host "  -->  $m" -ForegroundColor Cyan   }
function Warn { param($m) Write-Host "  [!]  $m" -ForegroundColor Yellow }
function Hdr  { param($m) Write-Host "`n===== $m =====" -ForegroundColor Cyan }
function Err  { param($m) Write-Host "  [HATA] $m" -ForegroundColor Red  }

function Write-File {
    param([string]$Path, [string]$Content)
    $dir = Split-Path $Path -Parent
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

$DESKTOP = [Environment]::GetFolderPath("Desktop")
$BACK    = Join-Path $DESKTOP "$ProjectName\backend"

Clear-Host
Write-Host @"

  ██████╗  ██████╗     ██████╗ ███████╗ ██████╗██╗███████╗
  ██╔══██╗██╔════╝    ██╔════╝ ██╔════╝██╔════╝██║██╔════╝
  ██████╔╝██║  ███╗   ██║  ███╗█████╗  ██║     ██║███████╗
  ██╔═══╝ ██║   ██║   ██║   ██║██╔══╝  ██║     ██║╚════██║
  ██║     ╚██████╔╝   ╚██████╔╝███████╗╚██████╗██║███████║
  ╚═╝      ╚═════╝     ╚═════╝ ╚══════╝ ╚═════╝╚═╝╚══════╝
    Firestore -> PostgreSQL + 3 Servisli Docker Compose
"@ -ForegroundColor Cyan

if (!(Test-Path $BACK)) {
    Err "$BACK bulunamadi. Once setup.ps1 calistirin."
    exit 1
}

Info "Hedef: $BACK"

# =============================================================================
# 1. DOCKER COMPOSE — 3 servis: backend + db + pgadmin
# =============================================================================
Hdr "docker-compose.yml guncelleniyor (3 servis)"

Write-File "$BACK\docker-compose.yml" @"
version: '3.9'

services:

  # ── 1. FastAPI Backend ─────────────────────────────────────────
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${ProjectName}-backend
    ports:
      - '8000:8000'
    env_file:
      - .env
    volumes:
      - ./service-account.json:/app/service-account.json:ro
      - .:/app
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:8000/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s

  # ── 2. PostgreSQL ──────────────────────────────────────────────
  db:
    image: postgres:16-alpine
    container_name: ${ProjectName}-db
    ports:
      - '5432:5432'
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres123
      POSTGRES_DB: ${ProjectName}_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s

  # ── 3. pgAdmin ─────────────────────────────────────────────────
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: ${ProjectName}-pgadmin
    ports:
      - '5050:80'
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - db
    restart: unless-stopped

volumes:
  postgres_data:
  pgadmin_data:
"@
Log "docker-compose.yml 3 servisli hale getirildi"

# =============================================================================
# 2. .ENV — PostgreSQL satirlari eklendi, Firestore kaldirildi
# =============================================================================
Hdr ".env guncelleniyor"

Write-File "$BACK\.env" @"
# ================================================================
# Gelistirme ortami
# ================================================================
PROJECT_NAME=${ProjectName} Backend
VERSION=1.0.0
DEBUG=True
API_V1_STR=/api/v1

# PostgreSQL — Docker icinde 'db' servis adini kullan
DATABASE_URL=postgresql+asyncpg://postgres:postgres123@db:5432/${ProjectName}_db

# Firebase (sadece Auth icin)
FIREBASE_CREDENTIALS_PATH=service-account.json
FIREBASE_PROJECT_ID=your-firebase-project-id

# CORS
ALLOWED_ORIGINS=["http://localhost:3000","http://localhost:8081","http://10.0.2.2:8000"]
ACCESS_TOKEN_EXPIRE_MINUTES=1440
"@
Log ".env guncellendi"

# =============================================================================
# 3. REQUIREMENTS.TXT — PostgreSQL kutuphaneleri eklendi
# =============================================================================
Hdr "requirements.txt guncelleniyor"

Write-File "$BACK\requirements.txt" @"
# Web Framework
fastapi==0.115.0
uvicorn[standard]==0.30.6

# PostgreSQL + Async ORM
sqlalchemy[asyncio]==2.0.35
asyncpg==0.29.0
alembic==1.13.2

# Pydantic v2
pydantic==2.9.2
pydantic-settings==2.5.2

# Firebase (sadece Auth)
firebase-admin==6.5.0

# HTTP
httpx==0.27.2

# Test
pytest==8.3.3
pytest-asyncio==0.24.0

# Kod kalitesi
ruff==0.6.9
"@
Log "requirements.txt guncellendi"

# =============================================================================
# 4. CORE — config.py (DATABASE_URL eklendi, Firestore kaldirildi)
# =============================================================================
Hdr "Core katmani guncelleniyor"

New-Item -ItemType Directory -Path "$BACK\app\core" -Force | Out-Null

Write-File "$BACK\app\core\config.py" @'
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator
from typing import List


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

    PROJECT_NAME: str = "MyApp Backend"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    API_V1_STR: str = "/api/v1"

    # PostgreSQL
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres123@db:5432/myapp"

    # Firebase (sadece Auth)
    FIREBASE_CREDENTIALS_PATH: str = "service-account.json"
    FIREBASE_PROJECT_ID: str = "your-project-id"

    # CORS
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440

    @field_validator("DATABASE_URL")
    @classmethod
    def validate_db_url(cls, v: str) -> str:
        if not v.startswith("postgresql+asyncpg"):
            raise ValueError("Async surucu (asyncpg) zorunludur.")
        return v


settings = Settings()
'@

Write-File "$BACK\app\core\database.py" @'
from sqlalchemy.ext.asyncio import (
    AsyncSession, create_async_engine, async_sessionmaker
)
from sqlalchemy.orm import DeclarativeBase
from app.core.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


class Base(DeclarativeBase):
    pass


async def get_db_session():
    """FastAPI Depends() ile kullanilan async DB oturumu."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
'@

Write-File "$BACK\app\core\firebase.py" @'
import firebase_admin
from firebase_admin import credentials
from app.core.config import settings


def initialize_firebase() -> None:
    """Firebase Admin SDK — sadece Auth icin, Firestore kullanilmiyor."""
    if firebase_admin._apps:
        return
    cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred, {
        "projectId": settings.FIREBASE_PROJECT_ID,
    })
'@

Write-File "$BACK\app\core\exceptions.py" @'
from typing import Optional, Any


class AppException(Exception):
    def __init__(self, status_code: int, error_code: str, message: str,
                 details: Optional[dict[str, Any]] = None):
        self.status_code = status_code
        self.error_code  = error_code
        self.message     = message
        self.details     = details
        super().__init__(message)


class NotFoundException(AppException):
    def __init__(self, resource: str, id: str):
        super().__init__(404, "NOT_FOUND", f"{resource} bulunamadi: {id}")


class UnauthorizedException(AppException):
    def __init__(self, code: str = "UNAUTHORIZED", msg: str = "Yetkisiz erisim."):
        super().__init__(401, code, msg)


class ForbiddenException(AppException):
    def __init__(self, msg: str = "Bu islem icin yetkiniz yok."):
        super().__init__(403, "FORBIDDEN", msg)
'@

Write-File "$BACK\app\core\__init__.py" ""
Log "Core katmani guncellendi"

# =============================================================================
# 5. MODELS — SQLAlchemy ORM (Firestore'dan donusum)
# =============================================================================
Hdr "ORM Modelleri olusturuluyor"

New-Item -ItemType Directory -Path "$BACK\app\models" -Force | Out-Null

Write-File "$BACK\app\models\__init__.py" @'
from .user import User
__all__ = ["User"]
'@

Write-File "$BACK\app\models\user.py" @'
from sqlalchemy import String, Boolean, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from datetime import datetime
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    firebase_uid: Mapped[str] = mapped_column(
        String(128), unique=True, index=True, nullable=False
    )
    email: Mapped[str] = mapped_column(
        String(255), unique=True, index=True, nullable=False
    )
    display_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), onupdate=func.now(), nullable=True
    )
'@

Log "ORM modelleri olusturuldu"

# =============================================================================
# 6. SCHEMAS
# =============================================================================
Hdr "Schemas guncelleniyor"

New-Item -ItemType Directory -Path "$BACK\app\schemas" -Force | Out-Null

Write-File "$BACK\app\schemas\__init__.py" @'
from .base import ResponseEnvelope, ErrorDetail, ok, fail
from .user import UserCreate, UserRead, UserUpdate
__all__ = ["ResponseEnvelope","ErrorDetail","ok","fail",
           "UserCreate","UserRead","UserUpdate"]
'@

Write-File "$BACK\app\schemas\base.py" @'
from typing import Generic, TypeVar, Optional, Any
from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Optional[dict[str, Any]] = None


class ResponseEnvelope(BaseModel, Generic[T]):
    """Flutter Dio interceptor bu yapıyı parse eder."""
    model_config = ConfigDict(arbitrary_types_allowed=True)
    success: bool
    data: Optional[T] = None
    error: Optional[ErrorDetail] = None
    meta: Optional[dict[str, Any]] = None


def ok(data: T, meta: Optional[dict] = None) -> ResponseEnvelope[T]:
    return ResponseEnvelope(success=True, data=data, meta=meta)


def fail(code: str, message: str, details: Optional[dict] = None) -> ResponseEnvelope:
    return ResponseEnvelope(
        success=False,
        error=ErrorDetail(code=code, message=message, details=details),
    )
'@

Write-File "$BACK\app\schemas\user.py" @'
from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class UserCreate(UserBase):
    firebase_uid: str


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    photo_url: Optional[str] = None


class UserRead(UserBase):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)
    id: str
    firebase_uid: str
    is_active: bool = True
    created_at: datetime
    updated_at: Optional[datetime] = None
'@

Log "Schemas guncellendi"

# =============================================================================
# 7. SERVICES — PostgreSQL tabanli CRUD
# =============================================================================
Hdr "Services katmani guncelleniyor"

New-Item -ItemType Directory -Path "$BACK\app\services\ai"    -Force | Out-Null
New-Item -ItemType Directory -Path "$BACK\app\services\video" -Force | Out-Null

Write-File "$BACK\app\services\__init__.py" @'
from .auth_service import AuthService
from .user_service import UserService
__all__ = ["AuthService", "UserService"]
'@

Write-File "$BACK\app\services\base.py" @'
from abc import ABC, abstractmethod
from typing import Generic, TypeVar, Optional, List
from sqlalchemy.ext.asyncio import AsyncSession

ModelT  = TypeVar("ModelT")
CreateT = TypeVar("CreateT")
UpdateT = TypeVar("UpdateT")


class BaseService(ABC, Generic[ModelT, CreateT, UpdateT]):
    def __init__(self, db: AsyncSession):
        self.db = db

    @abstractmethod
    async def get_by_id(self, id: str) -> Optional[ModelT]: ...

    @abstractmethod
    async def get_all(self, skip: int = 0, limit: int = 20) -> List[ModelT]: ...

    @abstractmethod
    async def create(self, schema: CreateT) -> ModelT: ...

    @abstractmethod
    async def update(self, id: str, schema: UpdateT) -> Optional[ModelT]: ...

    @abstractmethod
    async def delete(self, id: str) -> bool: ...
'@

Write-File "$BACK\app\services\auth_service.py" @'
import asyncio
import logging
from firebase_admin import auth as firebase_auth
from app.core.exceptions import UnauthorizedException

logger = logging.getLogger(__name__)


class AuthService:
    """Firebase Auth token dogrulama — thread pool ile async."""

    async def verify_token(self, token: str) -> dict:
        loop = asyncio.get_event_loop()
        try:
            decoded = await loop.run_in_executor(
                None,
                lambda: firebase_auth.verify_id_token(
                    token, check_revoked=True, clock_skew_seconds=10
                ),
            )
            logger.debug(f"Token dogrulandi: uid={decoded.get('uid')}")
            return decoded
        except firebase_auth.RevokedIdTokenError:
            raise UnauthorizedException("TOKEN_REVOKED", "Oturum sonlandirilmis.")
        except firebase_auth.ExpiredIdTokenError:
            raise UnauthorizedException("TOKEN_EXPIRED", "Token suresi dolmus.")
        except firebase_auth.InvalidIdTokenError:
            raise UnauthorizedException("INVALID_TOKEN", "Gecersiz token.")
        except Exception as e:
            logger.error(f"Token hatasi: {e}")
            raise UnauthorizedException("AUTH_ERROR", "Kimlik dogrulama hatasi.")
'@

Write-File "$BACK\app\services\user_service.py" @'
import uuid
from typing import Optional, List
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.base import BaseService
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.exceptions import NotFoundException


class UserService(BaseService[User, UserCreate, UserUpdate]):

    def __init__(self, db: AsyncSession):
        super().__init__(db)

    async def get_by_id(self, id: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.id == id))
        return r.scalar_one_or_none()

    async def get_by_firebase_uid(self, uid: str) -> Optional[User]:
        r = await self.db.execute(select(User).where(User.firebase_uid == uid))
        return r.scalar_one_or_none()

    async def get_all(self, skip: int = 0, limit: int = 20) -> List[User]:
        r = await self.db.execute(select(User).offset(skip).limit(limit))
        return list(r.scalars().all())

    async def create(self, schema: UserCreate) -> User:
        user = User(
            id=str(uuid.uuid4()),
            firebase_uid=schema.firebase_uid,
            email=schema.email,
            display_name=schema.display_name,
            photo_url=schema.photo_url,
        )
        self.db.add(user)
        await self.db.flush()
        return user

    async def update(self, id: str, schema: UserUpdate) -> Optional[User]:
        user = await self.get_by_id(id)
        if not user:
            raise NotFoundException("Kullanici", id)
        for field, value in schema.model_dump(exclude_none=True).items():
            setattr(user, field, value)
        await self.db.flush()
        return user

    async def delete(self, id: str) -> bool:
        user = await self.get_by_id(id)
        if not user:
            return False
        await self.db.delete(user)
        return True

    async def get_or_create_by_firebase_uid(self, uid: str, email: str) -> User:
        user = await self.get_by_firebase_uid(uid)
        if not user:
            user = await self.create(UserCreate(firebase_uid=uid, email=email))
        return user
'@

Write-File "$BACK\app\services\ai\__init__.py" ""
Write-File "$BACK\app\services\ai\base_nlp.py" @'
from abc import ABC, abstractmethod

class BaseNLPService(ABC):
    @abstractmethod
    async def analyze_text(self, text: str) -> dict: ...
    @abstractmethod
    async def embed(self, text: str) -> list[float]: ...
    @abstractmethod
    async def classify(self, text: str, labels: list[str]) -> dict: ...
'@

Write-File "$BACK\app\services\video\__init__.py" ""
Write-File "$BACK\app\services\video\base_video.py" @'
from abc import ABC, abstractmethod

class BaseVideoService(ABC):
    @abstractmethod
    async def process_frame(self, frame_bytes: bytes) -> dict: ...
    @abstractmethod
    async def start_stream(self, session_id: str) -> None: ...
    @abstractmethod
    async def stop_stream(self, session_id: str) -> None: ...
'@

Log "Services katmani guncellendi"

# =============================================================================
# 8. API KATMANI
# =============================================================================
Hdr "API katmani guncelleniyor"

New-Item -ItemType Directory -Path "$BACK\app\api\v1" -Force | Out-Null

Write-File "$BACK\app\api\__init__.py" ""
Write-File "$BACK\app\api\v1\__init__.py" ""

Write-File "$BACK\app\api\dependencies.py" @'
from typing import Annotated
from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.exceptions import UnauthorizedException
from app.services.auth_service import AuthService
from app.services.user_service import UserService
from app.schemas.user import UserRead

_auth_service  = AuthService()
_bearer_scheme = HTTPBearer(auto_error=False)

DBSession = Annotated[AsyncSession, Depends(get_db_session)]


async def get_current_user(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None,
        Depends(_bearer_scheme)
    ] = None,
    db: DBSession = None,
) -> UserRead:
    """Bearer token dogrular, PostgreSQL'den kullaniciyi getirir/olusturur."""
    if not credentials or not credentials.credentials:
        raise UnauthorizedException(
            "MISSING_TOKEN",
            "Authorization header eksik. Format: Bearer <firebase_id_token>",
        )
    token = credentials.credentials
    decoded = await _auth_service.verify_token(token)
    svc = UserService(db)
    user = await svc.get_or_create_by_firebase_uid(
        uid=decoded["uid"],
        email=decoded.get("email", ""),
    )
    return UserRead.model_validate(user)


CurrentUser = Annotated[UserRead, Depends(get_current_user)]
'@

Write-File "$BACK\app\api\middleware.py" @'
import time, logging
from fastapi import Request

logger = logging.getLogger("uvicorn.access")

async def timing_middleware(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    ms = (time.perf_counter() - start) * 1000
    response.headers["X-Process-Time"] = f"{ms:.2f}ms"
    logger.info(
        f"{request.method} {request.url.path} "
        f"-> {response.status_code} ({ms:.1f}ms)"
    )
    return response
'@

Write-File "$BACK\app\api\v1\auth.py" @'
from fastapi import APIRouter
from app.api.dependencies import CurrentUser
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.user import UserRead

router = APIRouter()


@router.get("/me", response_model=ResponseEnvelope[UserRead])
async def get_me(current_user: CurrentUser):
    """Mevcut kullanici profilini doner."""
    return ok(current_user)


@router.post("/verify", response_model=ResponseEnvelope[dict])
async def verify_token(current_user: CurrentUser):
    """Token gecerliligi test endpoint'i."""
    return ok({
        "uid":   current_user.firebase_uid,
        "email": current_user.email,
        "valid": True,
    })
'@

Write-File "$BACK\app\api\v1\users.py" @'
from fastapi import APIRouter
from app.api.dependencies import CurrentUser, DBSession
from app.services.user_service import UserService
from app.schemas.base import ResponseEnvelope, ok
from app.schemas.user import UserRead, UserUpdate
from app.core.exceptions import NotFoundException

router = APIRouter()


@router.get("/", response_model=ResponseEnvelope[list[UserRead]])
async def list_users(current_user: CurrentUser, db: DBSession,
                     skip: int = 0, limit: int = 20):
    svc = UserService(db)
    users = await svc.get_all(skip=skip, limit=limit)
    return ok([UserRead.model_validate(u) for u in users],
              meta={"skip": skip, "limit": limit, "count": len(users)})


@router.get("/{user_id}", response_model=ResponseEnvelope[UserRead])
async def get_user(user_id: str, current_user: CurrentUser, db: DBSession):
    svc = UserService(db)
    user = await svc.get_by_id(user_id)
    if not user:
        raise NotFoundException("Kullanici", user_id)
    return ok(UserRead.model_validate(user))


@router.patch("/{user_id}", response_model=ResponseEnvelope[UserRead])
async def update_user(user_id: str, body: UserUpdate,
                      current_user: CurrentUser, db: DBSession):
    svc = UserService(db)
    user = await svc.update(user_id, body)
    return ok(UserRead.model_validate(user))


@router.delete("/{user_id}", response_model=ResponseEnvelope[None])
async def delete_user(user_id: str, current_user: CurrentUser, db: DBSession):
    svc = UserService(db)
    if not await svc.delete(user_id):
        raise NotFoundException("Kullanici", user_id)
    return ok(None)
'@

Log "API katmani guncellendi"

# =============================================================================
# 9. MAIN.PY — PostgreSQL lifespan + tablo olusturma
# =============================================================================
Hdr "main.py guncelleniyor"

Write-File "$BACK\main.py" @'
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer

from app.core.config import settings
from app.core.firebase import initialize_firebase
from app.core.database import engine, Base
from app.core.exceptions import AppException
from app.schemas.base import ResponseEnvelope, ErrorDetail
from app.api.middleware import timing_middleware
from app.api.v1 import auth, users


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Baslat: Firebase + PostgreSQL tablolarini olustur."""
    initialize_firebase()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan,
)

app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.middleware("http")(timing_middleware)


@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content=ResponseEnvelope(
            success=False,
            error=ErrorDetail(
                code=exc.error_code,
                message=exc.message,
                details=exc.details,
            ),
        ).model_dump(),
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content=ResponseEnvelope(
            success=False,
            error=ErrorDetail(
                code="INTERNAL_SERVER_ERROR",
                message="Beklenmeyen bir hata olustu.",
            ),
        ).model_dump(),
    )


app.include_router(auth.router,  prefix=f"{settings.API_V1_STR}/auth",  tags=["auth"])
app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["users"])


@app.get("/health", tags=["system"])
async def health_check():
    return ResponseEnvelope(
        success=True,
        data={"status": "ok", "version": settings.VERSION},
    )
'@

Log "main.py guncellendi"

# =============================================================================
# 10. DOCKERFILE — curl eklendi (healthcheck icin)
# =============================================================================
Hdr "Dockerfile guncelleniyor"

Write-File "$BACK\Dockerfile" @"
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
"@
Log "Dockerfile guncellendi (curl + libpq-dev eklendi)"

# =============================================================================
# 11. GIT COMMIT
# =============================================================================
Hdr "Git commit"

Push-Location (Join-Path $DESKTOP $ProjectName)
if (Get-Command git -ErrorAction SilentlyContinue) {
    git add . 2>$null
    git commit -m "migrate: Firestore -> PostgreSQL + 3 servisli Docker Compose" -q 2>$null
    Log "Git commit atildi"
} else {
    Warn "Git bulunamadi"
}
Pop-Location

# =============================================================================
# OZET + SONRAKI ADIMLAR
# =============================================================================
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     Script tamamlandi! Simdi Docker adimlarini izle.         ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Ne degisti:" -ForegroundColor White
Write-Host "  [+] docker-compose.yml  -> 3 servis (backend + db + pgadmin)" -ForegroundColor Green
Write-Host "  [+] PostgreSQL ORM      -> SQLAlchemy async + asyncpg"         -ForegroundColor Green
Write-Host "  [+] Tablolar            -> main.py lifespan'de otomatik olusur" -ForegroundColor Green
Write-Host "  [-] Firestore           -> tamamen kaldirildi"                   -ForegroundColor Red
Write-Host ""
Write-Host "  SIRADAKI ADIMLAR:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Docker Desktop'in calistigini dogrula:" -ForegroundColor Yellow
Write-Host "     docker ps"                               -ForegroundColor White
Write-Host ""
Write-Host "  2. .env dosyasinda FIREBASE_PROJECT_ID'yi guncelle:" -ForegroundColor Yellow
Write-Host "     notepad `"$BACK\.env`""                           -ForegroundColor White
Write-Host ""
Write-Host "  3. Sistemi baslat (ilk seferinde image build edilir, 3-5 dk):" -ForegroundColor Yellow
Write-Host "     cd `"$BACK`""                                                 -ForegroundColor White
Write-Host "     docker-compose up --build"                                    -ForegroundColor White
Write-Host ""
Write-Host "  4. Her sey ayakta mi kontrol et:" -ForegroundColor Yellow
Write-Host "     docker-compose ps"              -ForegroundColor White
Write-Host ""
Write-Host "  5. Erisim noktalari:" -ForegroundColor Yellow
Write-Host "     API      -> http://localhost:8000/docs"  -ForegroundColor White
Write-Host "     pgAdmin  -> http://localhost:5050"       -ForegroundColor White
Write-Host "     DB login -> admin@admin.com / admin123"  -ForegroundColor White
Write-Host ""
