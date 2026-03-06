import os
from dotenv import load_dotenv


load_dotenv()


def _csv_to_list(value: str) -> list[str]:
    return [item.strip() for item in value.split(",") if item.strip()]


def _to_bool(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


class Settings:
    APP_NAME: str = os.getenv("APP_NAME", "AI Job Automation Backend")
    API_V1_PREFIX: str = os.getenv("API_V1_PREFIX", "")
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg2://postgres:postgres@localhost:5432/job_automation",
    )
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "change-this-secret-in-production")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_EXPIRE_MINUTES: int = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))

    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    CELERY_TIMEZONE: str = os.getenv("CELERY_TIMEZONE", "UTC")
    GREENHOUSE_COMPANIES: list[str] = _csv_to_list(
        os.getenv("GREENHOUSE_COMPANIES", "stripe,airbnb,shopify")
    )
    LEVER_COMPANIES: list[str] = _csv_to_list(
        os.getenv("LEVER_COMPANIES", "netflix,figma,coinbase")
    )

    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    OPENAI_CHAT_MODEL: str = os.getenv("OPENAI_CHAT_MODEL", "gpt-4o-mini")
    OPENAI_EMBEDDING_MODEL: str = os.getenv("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")
    RESUME_UPLOAD_DIR: str = os.getenv("RESUME_UPLOAD_DIR", "uploads/resumes")

    PLAYWRIGHT_HEADLESS: bool = _to_bool(os.getenv("PLAYWRIGHT_HEADLESS", "true"))
    PLAYWRIGHT_TIMEOUT_MS: int = int(os.getenv("PLAYWRIGHT_TIMEOUT_MS", "30000"))


settings = Settings()
