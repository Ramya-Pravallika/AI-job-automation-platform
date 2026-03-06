import json
from datetime import UTC, datetime

import requests
from bs4 import BeautifulSoup


YC_JOBS_URL = "https://www.ycombinator.com/jobs"
REQUEST_TIMEOUT = 20
HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; JobAutomationBot/1.0; +https://example.com/bot)",
}


def _extract_next_data(html: str) -> dict:
    soup = BeautifulSoup(html, "html.parser")
    script = soup.find("script", {"id": "__NEXT_DATA__"})
    if script is None or not script.string:
        return {}
    try:
        return json.loads(script.string)
    except json.JSONDecodeError:
        return {}


def _parse_datetime(value: str | None) -> datetime | None:
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


def _find_job_lists(node: object, found: list[dict]) -> None:
    if isinstance(node, dict):
        if all(key in node for key in ["title", "companyName"]):
            found.append(node)
        for value in node.values():
            _find_job_lists(value, found)
    elif isinstance(node, list):
        for item in node:
            _find_job_lists(item, found)


def scrape_yc_jobs() -> list[dict]:
    response = requests.get(YC_JOBS_URL, headers=HEADERS, timeout=REQUEST_TIMEOUT)
    response.raise_for_status()

    next_data = _extract_next_data(response.text)
    raw_jobs: list[dict] = []
    _find_job_lists(next_data, raw_jobs)

    normalized: list[dict] = []
    for item in raw_jobs:
        title = (item.get("title") or "").strip()
        company = (item.get("companyName") or "").strip()
        apply_url = item.get("applyUrl") or item.get("url") or ""
        if not title or not company or not apply_url:
            continue

        normalized.append(
            {
                "title": title,
                "company": company,
                "location": (item.get("location") or "Remote").strip(),
                "description": item.get("description") or "",
                "salary": item.get("salary") or None,
                "source": "ycombinator",
                "apply_url": apply_url,
                "posted_date": _parse_datetime(item.get("publishedAt") or item.get("postedAt")),
            }
        )

    unique: dict[tuple[str, str, str], dict] = {}
    for job in normalized:
        key = (job["company"].lower(), job["title"].lower(), job["location"].lower())
        unique[key] = job
    return list(unique.values())
