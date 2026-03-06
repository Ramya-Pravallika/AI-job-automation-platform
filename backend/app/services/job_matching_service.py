from fastapi import HTTPException, status
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy.orm import Session
import numpy as np

from app.models.job import Job
from app.models.resume import Resume
from app.models.user import User
from app.services.ai_service import generate_embeddings


def get_ranked_jobs_for_user(db: Session, user: User, limit: int = 20) -> list[dict]:
    resume = (
        db.query(Resume)
        .filter(Resume.user_id == user.id)
        .order_by(Resume.created_at.desc())
        .first()
    )
    if resume is None or not resume.parsed_text:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Resume not found. Upload a resume first.",
        )

    jobs = db.query(Job).filter(Job.description.isnot(None)).all()
    if not jobs:
        return []

    resume_text = resume.parsed_text
    job_texts = [
        f"Title: {job.title}\nCompany: {job.company}\nLocation: {job.location or ''}\nDescription: {job.description or ''}"
        for job in jobs
    ]

    vectors = generate_embeddings([resume_text] + job_texts)
    resume_vector = np.array(vectors[0]).reshape(1, -1)
    job_matrix = np.array(vectors[1:])

    scores = cosine_similarity(resume_vector, job_matrix).flatten()

    ranked = []
    for job, score in zip(jobs, scores, strict=False):
        ranked.append(
            {
                "id": job.id,
                "title": job.title,
                "company": job.company,
                "location": job.location,
                "match_score": round(float(score), 4),
            }
        )

    ranked.sort(key=lambda item: item["match_score"], reverse=True)
    return ranked[:limit]
