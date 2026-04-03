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


class ValidationException(AppException):
    def __init__(self, details: dict[str, Any]):
        super().__init__(422, "VALIDATION_ERROR", "Girdi dogrulama hatasi.", details)