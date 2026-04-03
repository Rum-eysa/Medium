from pydantic_settings import BaseSettings, SettingsConfigDict
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

    # Firebase / Firestore
    FIREBASE_CREDENTIALS_PATH: str = "service-account.json"
    FIREBASE_PROJECT_ID: str = "your-project-id"
    FIRESTORE_USERS_COLLECTION: str = "users"

    # CORS
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440


settings = Settings()