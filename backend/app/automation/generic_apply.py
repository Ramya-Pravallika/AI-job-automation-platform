import logging
from pathlib import Path

from playwright.sync_api import Page


logger = logging.getLogger(__name__)


def apply_generic(
    page: Page,
    apply_url: str,
    full_name: str,
    email: str,
    phone: str,
    resume_path: str,
    cover_letter: str,
) -> dict:
    logger.info("Starting generic auto-apply for %s", apply_url)
    try:
        page.goto(apply_url, wait_until="domcontentloaded")

        for selector, value in [
            ("input[name*='name']", full_name),
            ("input[type='email']", email),
            ("input[type='tel']", phone),
            ("textarea[name*='cover']", cover_letter),
        ]:
            field = page.locator(selector).first
            if field.count() > 0 and value:
                field.fill(value)

        file_input = page.locator("input[type='file']").first
        if file_input.count() > 0 and Path(resume_path).exists():
            file_input.set_input_files(resume_path)

        submit = page.locator("button[type='submit'], input[type='submit']").first
        if submit.count() == 0:
            return {"status": "requires_manual_review", "message": "No submit button found"}

        submit.click()
        page.wait_for_timeout(3000)
        return {"status": "requires_manual_review", "message": "Generic submission attempted"}
    except Exception as exc:
        logger.exception("Generic auto-apply failed")
        return {"status": "failed", "message": str(exc)}
