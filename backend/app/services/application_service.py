from fastapi import HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.models.application import Application
from app.models.job import Job
from app.models.user import User


def apply_to_job(db: Session, user: User, job_id: int, cover_letter: str | None = None) -> Application:
    job = db.query(Job).filter(Job.id == job_id).first()
    if job is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")

    existing = (
        db.query(Application)
        .filter(Application.user_id == user.id, Application.job_id == job_id)
        .first()
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already applied to this job",
        )

    application = Application(
        user_id=user.id,
        job_id=job_id,
        status="applied",
        cover_letter=cover_letter,
    )
    db.add(application)
    db.commit()
    db.refresh(application)
    return application


def list_user_applications(db: Session, user: User) -> list[Application]:
    return (
        db.query(Application)
        .options(joinedload(Application.job))
        .filter(Application.user_id == user.id)
        .order_by(Application.applied_at.desc())
        .all()
    )
