import logging

from sqlalchemy.orm import Session

from app.automation.auto_apply_service import auto_apply_to_job
from app.config import settings
from app.database import SessionLocal
from app.scrapers.greenhouse_scraper import scrape_greenhouse_jobs as scrape_greenhouse
from app.scrapers.lever_scraper import scrape_lever_jobs as scrape_lever
from app.scrapers.remoteok_scraper import scrape_remoteok_jobs as scrape_remoteok
from app.scrapers.yc_scraper import scrape_yc_jobs as scrape_yc
from app.services.job_ingestion_service import ingest_jobs
from workers.worker import celery_app


logger = logging.getLogger(__name__)


def _ingest(scraped_jobs: list[dict]) -> dict[str, int]:
    db: Session = SessionLocal()
    try:
        return ingest_jobs(db=db, jobs=scraped_jobs)
    finally:
        db.close()


@celery_app.task(name="workers.tasks.scrape_remoteok_jobs")
def scrape_remoteok_jobs() -> dict[str, int]:
    return _ingest(scrape_remoteok())


@celery_app.task(name="workers.tasks.scrape_greenhouse_jobs")
def scrape_greenhouse_jobs() -> dict[str, int]:
    aggregated: list[dict] = []
    for company in settings.GREENHOUSE_COMPANIES:
        aggregated.extend(scrape_greenhouse(company=company))
    return _ingest(aggregated)


@celery_app.task(name="workers.tasks.scrape_lever_jobs")
def scrape_lever_jobs() -> dict[str, int]:
    aggregated: list[dict] = []
    for company in settings.LEVER_COMPANIES:
        aggregated.extend(scrape_lever(company=company))
    return _ingest(aggregated)


@celery_app.task(name="workers.tasks.scrape_yc_jobs")
def scrape_yc_jobs() -> dict[str, int]:
    return _ingest(scrape_yc())


@celery_app.task(name="workers.tasks.auto_apply_job")
def auto_apply_job(user_id: int, job_id: int) -> dict:
    db: Session = SessionLocal()
    try:
        return auto_apply_to_job(db=db, user_id=user_id, job_id=job_id)
    finally:
        db.close()


@celery_app.task(name="workers.tasks.auto_apply_batch")
def auto_apply_batch(user_id: int, job_ids: list[int]) -> dict:
    results: list[dict] = []
    db: Session = SessionLocal()
    try:
        for job_id in job_ids:
            try:
                results.append(auto_apply_to_job(db=db, user_id=user_id, job_id=job_id))
            except Exception as exc:
                logger.exception("Batch auto-apply failed for job_id=%s", job_id)
                results.append({"job_id": job_id, "status": "failed", "message": str(exc)})
        submitted = sum(1 for item in results if item.get("status") == "submitted")
        return {
            "total": len(job_ids),
            "submitted": submitted,
            "results": results,
        }
    finally:
        db.close()
