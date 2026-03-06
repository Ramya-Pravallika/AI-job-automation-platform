from fastapi import HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.models.job import Job


def list_jobs(
    db: Session,
    query: str | None = None,
    location: str | None = None,
    source: str | None = None,
) -> list[Job]:
    jobs_query = db.query(Job)

    if query:
        pattern = f"%{query.strip()}%"
        jobs_query = jobs_query.filter(
            or_(Job.title.ilike(pattern), Job.company.ilike(pattern), Job.description.ilike(pattern))
        )

    if location:
        jobs_query = jobs_query.filter(Job.location.ilike(f"%{location.strip()}%"))

    if source:
        jobs_query = jobs_query.filter(Job.source.ilike(f"%{source.strip()}%"))

    return jobs_query.order_by(Job.created_at.desc()).all()


def get_job_by_id(db: Session, job_id: int) -> Job:
    job = db.query(Job).filter(Job.id == job_id).first()
    if job is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")
    return job
