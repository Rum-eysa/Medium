from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.core.database import engine, Base
from app.core.exceptions import AppException
from app.schemas.base import ResponseEnvelope, ErrorDetail
from app.api.middleware import timing_middleware
from app.api.v1 import auth, users, articles, comments, notifications, reading_list, search

import app.models  # noqa: F401


@asynccontextmanager
async def lifespan(app: FastAPI):
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
    allow_origin_regex=(
        r"^https?://("
        r"localhost|"
        r"127\.0\.0\.1|"
        r"0\.0\.0\.0|"
        r"\[::1\]|"
        r"10\.\d{1,3}\.\d{1,3}\.\d{1,3}|"
        r"172\.(1[6-9]|2\d|3[0-1])\.\d{1,3}\.\d{1,3}|"
        r"192\.168\.\d{1,3}\.\d{1,3}"
        r")(:\d+)?$"
    ),
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


app.include_router(auth.router,     prefix=f"{settings.API_V1_STR}/auth",     tags=["auth"])
app.include_router(users.router,    prefix=f"{settings.API_V1_STR}/users",    tags=["users"])
app.include_router(articles.router, prefix=f"{settings.API_V1_STR}/articles", tags=["articles"])
app.include_router(comments.router,     prefix=f"{settings.API_V1_STR}/articles", tags=["comments"])
app.include_router(notifications.router, prefix=f"{settings.API_V1_STR}/notifications", tags=["notifications"])
app.include_router(reading_list.router,  prefix=f"{settings.API_V1_STR}/reading-list", tags=["reading-list"])
app.include_router(search.router,        prefix=f"{settings.API_V1_STR}/search", tags=["search"])


@app.get("/health", tags=["system"])
async def health_check():
    return ResponseEnvelope(
        success=True,
        data={"status": "ok", "version": settings.VERSION},
    )
