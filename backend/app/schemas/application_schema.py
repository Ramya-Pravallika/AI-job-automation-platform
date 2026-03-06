from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.schemas.job_schema import JobResponse


class ApplyRequest(BaseModel):
    job_id: int
    cover_letter: str | None = None


class AutoApplyRequest(BaseModel):
    job_id: int


class AutoApplyBatchRequest(BaseModel):
    job_ids: list[int]


class TaskEnqueueResponse(BaseModel):
    task_id: str
    message: str


class BatchTaskEnqueueResponse(BaseModel):
    task_id: str
    total_jobs: int
    message: str


class ApplicationResponse(BaseModel):
    id: int
    user_id: int
    job_id: int
    status: str
    cover_letter: str | None
    applied_at: datetime
    job: JobResponse

    model_config = ConfigDict(from_attributes=True)
