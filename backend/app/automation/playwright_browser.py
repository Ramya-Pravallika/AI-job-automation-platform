import logging
from dataclasses import dataclass

from playwright.sync_api import Browser, BrowserContext, Page, Playwright, sync_playwright


logger = logging.getLogger(__name__)


@dataclass
class BrowserSession:
    playwright: Playwright
    browser: Browser
    context: BrowserContext
    page: Page


def create_browser(headless: bool = True, timeout_ms: int = 30000) -> BrowserSession:
    logger.info("Launching Playwright browser (headless=%s)", headless)
    playwright = sync_playwright().start()
    browser = playwright.chromium.launch(headless=headless)
    context = browser.new_context()
    page = context.new_page()
    page.set_default_timeout(timeout_ms)
    return BrowserSession(playwright=playwright, browser=browser, context=context, page=page)


def create_page(session: BrowserSession) -> Page:
    return session.page


def close_browser(session: BrowserSession) -> None:
    logger.info("Closing Playwright browser session")
    try:
        session.context.close()
    finally:
        try:
            session.browser.close()
        finally:
            session.playwright.stop()
