from datetime import datetime

from pydantic import BaseModel, ConfigDict


class JobResponse(BaseModel):
    id: int
    title: str
    company: str
    location: str | None
    description: str | None
    salary: str | None
    source: str | None
    apply_url: str | None
    posted_date: datetime | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
