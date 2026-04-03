from typing import Generic, TypeVar, Optional, Any
from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Optional[dict[str, Any]] = None


class ResponseEnvelope(BaseModel, Generic[T]):
    """
    Tum API yanitlari bu zarf icinde doner.
    Flutter Dio interceptor bu yapıyı otomatik parse eder.
    """
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