from pydantic import BaseModel


class MatchedJobResponse(BaseModel):
    id: int
    title: str
    company: str
    location: str | None
    match_score: float


class CoverLetterGenerateRequest(BaseModel):
    job_id: int


class CoverLetterGenerateResponse(BaseModel):
    job_id: int
    cover_letter: str
