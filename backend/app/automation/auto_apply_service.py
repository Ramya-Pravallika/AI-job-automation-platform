import logging
from pathlib import Path

from sqlalchemy.orm import Session

from app.automation.generic_apply import apply_generic
from app.automation.greenhouse_apply import apply_on_greenhouse
from app.automation.lever_apply import apply_on_lever
from app.automation.playwright_browser import close_browser, create_browser, create_page
from app.config import settings
from app.models.application import Application
from app.models.job import Job
from app.models.profile import Profile
from app.models.resume import Resume
from app.models.user import User
from app.services.ai_service import generate_cover_letter


logger = logging.getLogger(__name__)


def _infer_full_name(profile: Profile | None, user: User) -> str:
    email_prefix = user.email.split("@")[0].replace(".", " ").replace("_", " ").title()
    if not email_prefix.strip():
        return "Job Applicant"
    return email_prefix


def _determine_platform(job: Job) -> str:
    source = (job.source or "").lower()
    url = (job.apply_url or "").lower()
    if "greenhouse" in source or "greenhouse" in url:
        return "greenhouse"
    if "lever" in source or "lever.co" in url:
        return "lever"
    return "generic"


def _upsert_application(
    db: Session,
    user_id: int,
    job_id: int,
    status: str,
    cover_letter: str | None,
) -> Application:
    existing = (
        db.query(Application)
        .filter(Application.user_id == user_id, Application.job_id == job_id)
        .first()
    )
    if existing is None:
        existing = Application(
            user_id=user_id,
            job_id=job_id,
            status=status,
            cover_letter=cover_letter,
        )
        db.add(existing)
    else:
        existing.status = status
        if cover_letter:
            existing.cover_letter = cover_letter

    db.commit()
    db.refresh(existing)
    return existing


def auto_apply_to_job(db: Session, user_id: int, job_id: int) -> dict:
    logger.info("Auto-apply started for user_id=%s job_id=%s", user_id, job_id)
    user = db.query(User).filter(User.id == user_id).first()
    job = db.query(Job).filter(Job.id == job_id).first()
    resume = (
        db.query(Resume)
        .filter(Resume.user_id == user_id)
        .order_by(Resume.created_at.desc())
        .first()
    )
    profile = db.query(Profile).filter(Profile.user_id == user_id).first()

    if user is None or job is None:
        logger.error("Auto-apply failed: user or job not found")
        return {"status": "failed", "message": "User or job not found", "job_id": job_id}

    if resume is None or not resume.file_path or not Path(resume.file_path).exists():
        _upsert_application(db, user_id=user_id, job_id=job_id, status="requires_manual_review", cover_letter=None)
        return {
            "status": "requires_manual_review",
            "message": "Resume file not found for automation",
            "job_id": job_id,
        }

    existing_application = (
        db.query(Application)
        .filter(Application.user_id == user_id, Application.job_id == job_id)
        .first()
    )
    cover_letter = existing_application.cover_letter if existing_application else None

    if not cover_letter:
        try:
            resume_text = resume.parsed_text or ""
            job_description = job.description or job.title
            cover_letter = generate_cover_letter(resume_text=resume_text, job_description=job_description)
        except Exception as exc:
            logger.warning("Cover letter generation failed; continuing without AI letter: %s", exc)
            cover_letter = ""

    phone = ""
    full_name = _infer_full_name(profile=profile, user=user)
    platform = _determine_platform(job)

    session = None
    result: dict
    try:
        session = create_browser(
            headless=settings.PLAYWRIGHT_HEADLESS,
            timeout_ms=settings.PLAYWRIGHT_TIMEOUT_MS,
        )
        page = create_page(session)

        logger.info("Routing auto-apply handler platform=%s", platform)
        if platform == "greenhouse":
            result = apply_on_greenhouse(
                page=page,
                apply_url=job.apply_url or "",
                full_name=full_name,
                email=user.email,
                phone=phone,
                resume_path=resume.file_path,
                cover_letter=cover_letter,
            )
        elif platform == "lever":
            result = apply_on_lever(
                page=page,
                apply_url=job.apply_url or "",
                full_name=full_name,
                email=user.email,
                phone=phone,
                resume_path=resume.file_path,
                cover_letter=cover_letter,
            )
        else:
            result = apply_generic(
                page=page,
                apply_url=job.apply_url or "",
                full_name=full_name,
                email=user.email,
                phone=phone,
                resume_path=resume.file_path,
                cover_letter=cover_letter,
            )
    except Exception as exc:
        logger.exception("Auto-apply execution failed")
        result = {"status": "failed", "message": str(exc)}
    finally:
        if session is not None:
            close_browser(session)

    status = result.get("status", "failed")
    _upsert_application(
        db=db,
        user_id=user_id,
        job_id=job_id,
        status=status,
        cover_letter=cover_letter,
    )

    logger.info("Auto-apply completed for job_id=%s with status=%s", job_id, status)
    return {
        "status": status,
        "message": result.get("message", ""),
        "job_id": job_id,
        "platform": platform,
    }
