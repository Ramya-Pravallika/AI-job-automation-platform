from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.job import Job
from app.models.resume import Resume
from app.models.user import User
from app.schemas.ai_schema import CoverLetterGenerateRequest, CoverLetterGenerateResponse
from app.services.ai_service import generate_cover_letter
from app.utils.security import get_current_user


router = APIRouter(prefix="/ai", tags=["ai"])


@router.post("/generate-cover-letter", response_model=CoverLetterGenerateResponse)
def generate_cover_letter_endpoint(
    payload: CoverLetterGenerateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> CoverLetterGenerateResponse:
    resume = (
        db.query(Resume)
        .filter(Resume.user_id == current_user.id)
        .order_by(Resume.created_at.desc())
        .first()
    )
    job = db.query(Job).filter(Job.id == payload.job_id).first()

    if resume is None or not resume.parsed_text:
        from fastapi import HTTPException, status

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Resume not found. Upload a resume first.",
        )
    if job is None:
        from fastapi import HTTPException, status

        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job not found")

    letter = generate_cover_letter(
        resume_text=resume.parsed_text,
        job_description=job.description or job.title,
    )
    return CoverLetterGenerateResponse(job_id=payload.job_id, cover_letter=letter)
