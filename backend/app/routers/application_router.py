from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.user import User
from app.schemas.application_schema import (
    ApplicationResponse,
    ApplyRequest,
    AutoApplyBatchRequest,
    AutoApplyRequest,
    BatchTaskEnqueueResponse,
    TaskEnqueueResponse,
)
from app.services.application_service import apply_to_job, list_user_applications
from app.utils.security import get_current_user
from workers.worker import celery_app


router = APIRouter(prefix="/applications", tags=["applications"])


@router.post("/apply", response_model=ApplicationResponse, status_code=status.HTTP_201_CREATED)
def apply(
    payload: ApplyRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ApplicationResponse:
    application = apply_to_job(
        db=db,
        user=current_user,
        job_id=payload.job_id,
        cover_letter=payload.cover_letter,
    )
    return application


@router.post("/auto-apply", response_model=TaskEnqueueResponse, status_code=status.HTTP_202_ACCEPTED)
def auto_apply(
    payload: AutoApplyRequest,
    current_user: User = Depends(get_current_user),
) -> TaskEnqueueResponse:
    task = celery_app.send_task(
        "workers.tasks.auto_apply_job",
        kwargs={"user_id": current_user.id, "job_id": payload.job_id},
    )
    return TaskEnqueueResponse(task_id=task.id, message="Auto-apply task queued")


@router.post(
    "/auto-apply-batch",
    response_model=BatchTaskEnqueueResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
def auto_apply_batch(
    payload: AutoApplyBatchRequest,
    current_user: User = Depends(get_current_user),
) -> BatchTaskEnqueueResponse:
    task = celery_app.send_task(
        "workers.tasks.auto_apply_batch",
        kwargs={"user_id": current_user.id, "job_ids": payload.job_ids},
    )
    return BatchTaskEnqueueResponse(
        task_id=task.id,
        total_jobs=len(payload.job_ids),
        message="Batch auto-apply task queued",
    )


@router.get("", response_model=list[ApplicationResponse])
def get_applications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> list[ApplicationResponse]:
    return list_user_applications(db=db, user=current_user)
