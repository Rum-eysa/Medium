from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.firebase import initialize_firebase
from app.core.exceptions import AppException
from app.schemas.base import ResponseEnvelope, ErrorDetail
from app.api.middleware import timing_middleware
from app.api.v1 import auth, users


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Baslat: Firebase Admin SDK ve Firestore client hazirla."""
    initialize_firebase()
    yield
    # Firebase baglantilari otomatik kapanir


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