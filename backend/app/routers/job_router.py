from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.ai_schema import MatchedJobResponse
from app.schemas.job_schema import JobResponse
from app.services.job_matching_service import get_ranked_jobs_for_user
from app.services.job_service import get_job_by_id, list_jobs
from app.utils.security import get_current_user


router = APIRouter(prefix="/jobs", tags=["jobs"])


@router.get("", response_model=list[JobResponse])
def get_jobs(
    query: str | None = Query(default=None),
    location: str | None = Query(default=None),
    source: str | None = Query(default=None),
    db: Session = Depends(get_db),
) -> list[JobResponse]:
    return list_jobs(db=db, query=query, location=location, source=source)


@router.get("/matched", response_model=list[MatchedJobResponse])
def get_matched_jobs(
    limit: int = Query(default=20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[MatchedJobResponse]:
    return get_ranked_jobs_for_user(db=db, user=current_user, limit=limit)


@router.get("/{job_id}", response_model=JobResponse)
def get_job(job_id: int, db: Session = Depends(get_db)) -> JobResponse:
    return get_job_by_id(db, job_id)
