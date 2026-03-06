from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ResumeUploadResponse(BaseModel):
    id: int
    user_id: int
    file_name: str
    file_type: str
    parsed_text: str | None
    skills_extracted: list[str] | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
