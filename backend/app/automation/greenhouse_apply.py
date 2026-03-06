import logging
from pathlib import Path

from playwright.sync_api import Page, TimeoutError as PlaywrightTimeoutError


logger = logging.getLogger(__name__)


def _fill_first(page: Page, selectors: list[str], value: str) -> bool:
    if not value:
        return False
    for selector in selectors:
        locator = page.locator(selector).first
        if locator.count() > 0:
            try:
                locator.fill(value)
                logger.info("Filled selector %s", selector)
                return True
            except Exception:
                logger.debug("Unable to fill selector %s", selector, exc_info=True)
    return False


def _upload_first(page: Page, selectors: list[str], file_path: str) -> bool:
    if not file_path or not Path(file_path).exists():
        return False
    for selector in selectors:
        locator = page.locator(selector).first
        if locator.count() > 0:
            try:
                locator.set_input_files(file_path)
                logger.info("Uploaded file using selector %s", selector)
                return True
            except Exception:
                logger.debug("Unable to upload with selector %s", selector, exc_info=True)
    return False


def apply_on_greenhouse(
    page: Page,
    apply_url: str,
    full_name: str,
    email: str,
    phone: str,
    resume_path: str,
    cover_letter: str,
) -> dict:
    logger.info("Starting Greenhouse auto-apply for %s", apply_url)
    try:
        page.goto(apply_url, wait_until="domcontentloaded")

        apply_cta = page.locator("text=Apply for this job").first
        if apply_cta.count() > 0:
            apply_cta.click()

        name_parts = full_name.split(" ", 1)
        first_name = name_parts[0]
        last_name = name_parts[1] if len(name_parts) > 1 else "Applicant"

        _fill_first(page, [
            "input[name='first_name']",
            "input[id*='first_name']",
            "input[autocomplete='given-name']",
        ], first_name)
        _fill_first(page, [
            "input[name='last_name']",
            "input[id*='last_name']",
            "input[autocomplete='family-name']",
        ], last_name)
        _fill_first(page, ["input[type='email']", "input[name='email']"], email)
        _fill_first(page, ["input[type='tel']", "input[name*='phone']"], phone)

        resume_uploaded = _upload_first(
            page,
            [
                "input[type='file'][name*='resume']",
                "input[type='file'][id*='resume']",
                "input[type='file']",
            ],
            resume_path,
        )

        _fill_first(
            page,
            [
                "textarea[name*='cover_letter']",
                "textarea[id*='cover_letter']",
                "textarea[aria-label*='Cover Letter']",
            ],
            cover_letter,
        )

        submitted = False
        for selector in [
            "button[type='submit']",
            "button:has-text('Submit Application')",
            "input[type='submit']",
        ]:
            button = page.locator(selector).first
            if button.count() > 0:
                button.click()
                submitted = True
                break

        if not submitted:
            logger.warning("Greenhouse submit button not found")
            return {"status": "requires_manual_review", "message": "Submit button not found"}

        try:
            page.wait_for_timeout(4000)
            content = page.content().lower()
            if "thank you" in content or "application submitted" in content:
                return {"status": "submitted", "message": "Application submitted successfully"}
        except PlaywrightTimeoutError:
            logger.debug("Timeout while waiting for confirmation", exc_info=True)

        if resume_uploaded:
            return {"status": "requires_manual_review", "message": "Submission attempted; confirmation not detected"}
        return {"status": "requires_manual_review", "message": "Resume upload may have failed"}
    except Exception as exc:
        logger.exception("Greenhouse auto-apply failed")
        return {"status": "failed", "message": str(exc)}
