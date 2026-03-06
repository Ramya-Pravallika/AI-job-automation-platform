from datetime import datetime
from typing import TypedDict

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.job import Job


class NormalizedJob(TypedDict):
    title: str
    company: str
    location: str
    description: str
    salary: str | None
    source: str
    apply_url: str
    posted_date: datetime | None


def ingest_jobs(db: Session, jobs: list[NormalizedJob]) -> dict[str, int]:
    inserted = 0
    duplicates = 0

    for scraped_job in jobs:
        title = scraped_job["title"].strip()
        company = scraped_job["company"].strip()
        location = (scraped_job.get("location") or "").strip()

        existing = (
            db.query(Job)
            .filter(
                func.lower(Job.title) == title.lower(),
                func.lower(Job.company) == company.lower(),
                func.lower(func.coalesce(Job.location, "")) == location.lower(),
            )
            .first()
        )
        if existing:
            duplicates += 1
            continue

        db.add(
            Job(
                title=title,
                company=company,
                location=location or None,
                description=(scraped_job.get("description") or "").strip() or None,
                salary=scraped_job.get("salary"),
                source=scraped_job.get("source"),
                apply_url=scraped_job.get("apply_url"),
                posted_date=scraped_job.get("posted_date"),
            )
        )
        inserted += 1

    db.commit()
    return {"inserted": inserted, "duplicates": duplicates, "received": len(jobs)}
