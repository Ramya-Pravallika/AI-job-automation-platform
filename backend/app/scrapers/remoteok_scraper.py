from datetime import UTC, datetime

import requests
from bs4 import BeautifulSoup


REMOTEOK_URL = "https://remoteok.com/remote-dev-jobs"
REQUEST_TIMEOUT = 20
HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; JobAutomationBot/1.0; +https://example.com/bot)",
}


def _parse_iso_datetime(value: str | None) -> datetime | None:
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


def scrape_remoteok_jobs() -> list[dict]:
    response = requests.get(REMOTEOK_URL, headers=HEADERS, timeout=REQUEST_TIMEOUT)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    jobs: list[dict] = []

    for row in soup.select("tr.job"):
        title_node = row.select_one("h2")
        company_node = row.select_one("h3")
        location_node = row.select_one("div.location")
        description_node = row.select_one("td.company_and_position")
        link_node = row.select_one("a.preventLink")

        title = title_node.get_text(strip=True) if title_node else ""
        company = company_node.get_text(strip=True) if company_node else ""
        if not title or not company:
            continue

        relative_url = link_node.get("href") if link_node else ""
        apply_url = f"https://remoteok.com{relative_url}" if relative_url.startswith("/") else relative_url

        jobs.append(
            {
                "title": title,
                "company": company,
                "location": location_node.get_text(strip=True) if location_node else "Remote",
                "description": description_node.get_text(" ", strip=True) if description_node else "",
                "salary": None,
                "source": "remoteok",
                "apply_url": apply_url,
                "posted_date": _parse_iso_datetime(row.get("data-date")),
            }
        )

    return jobs
