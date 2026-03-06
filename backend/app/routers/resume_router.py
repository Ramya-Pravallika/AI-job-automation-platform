from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models.resume import Resume
from app.models.user import User
from app.schemas.resume_schema import ResumeUploadResponse
from app.services.resume_parser_service import parse_resume
from app.utils.security import get_current_user


router = APIRouter(prefix="/resume", tags=["resume"])


@router.post("/upload", response_model=ResumeUploadResponse, status_code=status.HTTP_201_CREATED)
async def upload_resume(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ResumeUploadResponse:
    extension = Path(file.filename or "").suffix.lower().lstrip(".")
    if extension not in {"pdf", "docx"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF and DOCX resume uploads are supported.",
        )

    upload_dir = Path(settings.RESUME_UPLOAD_DIR)
    upload_dir.mkdir(parents=True, exist_ok=True)

    safe_name = f"{current_user.id}_{uuid4().hex}.{extension}"
    target_path = upload_dir / safe_name
    content = await file.read()
    target_path.write_bytes(content)

    parsed = parse_resume(file_path=target_path, file_type=extension)

    resume = Resume(
        user_id=current_user.id,
        file_name=file.filename or safe_name,
        file_type=extension,
        file_path=str(target_path),
        parsed_text=parsed["parsed_text"],
        skills_extracted=parsed["skills_extracted"],
    )
    db.add(resume)
    db.commit()
    db.refresh(resume)

    return resume
