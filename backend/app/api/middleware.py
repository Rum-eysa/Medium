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