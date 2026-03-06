import logging
from pathlib import Path

from playwright.sync_api import Page


logger = logging.getLogger(__name__)


def _fill_if_present(page: Page, selector: str, value: str) -> bool:
    if not value:
        return False
    locator = page.locator(selector).first
    if locator.count() == 0:
        return False
    locator.fill(value)
    logger.info("Filled %s", selector)
    return True


def apply_on_lever(
    page: Page,
    apply_url: str,
    full_name: str,
    email: str,
    phone: str,
    resume_path: str,
    cover_letter: str,
) -> dict:
    logger.info("Starting Lever auto-apply for %s", apply_url)
    try:
        page.goto(apply_url, wait_until="domcontentloaded")

        _fill_if_present(page, "input[name='name']", full_name)
        _fill_if_present(page, "input[name='email']", email)
        _fill_if_present(page, "input[name='phone']", phone)

        file_input = page.locator("input[type='file']").first
        if file_input.count() > 0 and Path(resume_path).exists():
            file_input.set_input_files(resume_path)
            logger.info("Resume uploaded for Lever")
        else:
            logger.warning("Lever resume input not found or file missing")

        _fill_if_present(
            page,
            "textarea[name='comments']",
            cover_letter,
        )

        submit_btn = page.locator("button[type='submit'], input[type='submit']").first
        if submit_btn.count() == 0:
            return {"status": "requires_manual_review", "message": "Submit button not found"}

        submit_btn.click()
        page.wait_for_timeout(4000)

        content = page.content().lower()
        if "thank" in content or "application submitted" in content:
            return {"status": "submitted", "message": "Application submitted successfully"}
        return {"status": "requires_manual_review", "message": "Submission attempted; confirmation not detected"}
    except Exception as exc:
        logger.exception("Lever auto-apply failed")
        return {"status": "failed", "message": str(exc)}
