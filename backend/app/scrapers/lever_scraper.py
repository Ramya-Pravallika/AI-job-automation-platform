from datetime import UTC, datetime

import requests


REQUEST_TIMEOUT = 20


def _parse_lever_datetime(value: int | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromtimestamp(value / 1000, tz=UTC)
    except (TypeError, ValueError):
        return None


def scrape_lever_jobs(company: str) -> list[dict]:
    url = f"https://api.lever.co/v0/postings/{company}"
    response = requests.get(url, params={"mode": "json"}, timeout=REQUEST_TIMEOUT)
    response.raise_for_status()

    payload = response.json()
    jobs: list[dict] = []

    for item in payload:
        categories = item.get("categories") or {}
        jobs.append(
            {
                "title": (item.get("text") or "").strip(),
                "company": company,
                "location": (categories.get("location") or "").strip(),
                "description": item.get("descriptionPlain", "") or "",
                "salary": item.get("salaryDescription"),
                "source": "lever",
                "apply_url": item.get("hostedUrl", "") or "",
                "posted_date": _parse_lever_datetime(item.get("createdAt")),
            }
        )

    return [job for job in jobs if job["title"] and job["apply_url"]]
