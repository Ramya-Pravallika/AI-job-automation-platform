import logging

from celery import Celery
from celery.schedules import crontab

from app.config import settings

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(name)s: %(message)s')


celery_app = Celery(
    "job_scraping_worker",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
    include=["workers.tasks"],
)

celery_app.conf.timezone = settings.CELERY_TIMEZONE
celery_app.conf.task_serializer = "json"
celery_app.conf.result_serializer = "json"
celery_app.conf.accept_content = ["json"]

celery_app.conf.beat_schedule = {
    "scrape-remoteok-every-30-min": {
        "task": "workers.tasks.scrape_remoteok_jobs",
        "schedule": crontab(minute="*/30"),
    },
    "scrape-greenhouse-every-1-hour": {
        "task": "workers.tasks.scrape_greenhouse_jobs",
        "schedule": crontab(minute=0),
    },
    "scrape-lever-every-1-hour": {
        "task": "workers.tasks.scrape_lever_jobs",
        "schedule": crontab(minute=0),
    },
    "scrape-yc-every-2-hours": {
        "task": "workers.tasks.scrape_yc_jobs",
        "schedule": crontab(minute=0, hour="*/2"),
    },
}

