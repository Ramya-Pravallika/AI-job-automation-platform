from fastapi import FastAPI

from app import models  # noqa: F401
from app.config import settings
from app.database import Base, engine
from app.routers.ai_router import router as ai_router
from app.routers.application_router import router as application_router
from app.routers.auth_router import router as auth_router
from app.routers.job_router import router as job_router
from app.routers.resume_router import router as resume_router
from app.routers.user_router import router as user_router


Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.APP_NAME)

app.include_router(auth_router)
app.include_router(user_router)
app.include_router(job_router)
app.include_router(application_router)
app.include_router(resume_router)
app.include_router(ai_router)


@app.get("/health", tags=["health"])
def health_check() -> dict[str, str]:
    return {"status": "ok"}
