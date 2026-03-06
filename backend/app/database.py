from collections.abc import Generator
import logging

from sqlalchemy import create_engine, text
from sqlalchemy.orm import declarative_base, sessionmaker

from app.config import settings


logger = logging.getLogger(__name__)


def _build_engine():
    database_url = settings.DATABASE_URL
    connect_args: dict[str, object] = {}

    if database_url.startswith("sqlite"):
        connect_args["check_same_thread"] = False
        return create_engine(database_url, connect_args=connect_args, pool_pre_ping=True)

    try:
        probe_engine = create_engine(database_url, pool_pre_ping=True)
        with probe_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return probe_engine
    except Exception as exc:
        if not settings.DATABASE_FALLBACK_TO_SQLITE:
            raise
        fallback_url = settings.SQLITE_FALLBACK_URL
        logger.warning(
            "Primary database unavailable (%s). Falling back to SQLite at %s",
            exc,
            fallback_url,
        )
        return create_engine(
            fallback_url,
            connect_args={"check_same_thread": False},
            pool_pre_ping=True,
        )


engine = _build_engine()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db() -> Generator:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
