from datetime import UTC, datetime

import requests


REQUEST_TIMEOUT = 20


def _parse_greenhouse_datetime(value: str | None) -> datetime | None:
    if not value:
        return None
    cleaned = value.replace("Z", "+00:00")
    try:
        parsed = datetime.fromisoformat(cleaned)
        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=UTC)
        return parsed
    except ValueError:
        return None


def scrape_greenhouse_jobs(company: str) -> list[dict]:
    url = f"https://boards-api.greenhouse.io/v1/boards/{company}/jobs"
    response = requests.get(url, timeout=REQUEST_TIMEOUT)
    response.raise_for_status()

    payload = response.json()
    jobs: list[dict] = []
    for item in payload.get("jobs", []):
        jobs.append(
            {
                "title": item.get("title", "").strip(),
                "company": company,
                "location": (item.get("location") or {}).get("name", "").strip(),
                "description": item.get("content", "") or "",
                "salary": None,
                "source": "greenhouse",
                "apply_url": item.get("absolute_url", "") or "",
                "posted_date": _parse_greenhouse_datetime(item.get("updated_at")),
            }
        )

    return [job for job in jobs if job["title"] and job["apply_url"]]
