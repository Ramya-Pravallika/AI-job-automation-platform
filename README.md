# AI Job Automation Platform

End-to-end AI job automation system with:
- FastAPI + PostgreSQL backend
- Celery + Redis background jobs
- Playwright automation engine
- Flutter frontend (Web + Android)

## Project Structure

```text
ai-job-automation-platform/
  backend/
    app/
    workers/
    requirements.txt
  frontend/
    lib/
    android/
    web/
    pubspec.yaml
```

## Prerequisites

- Python 3.11+
- Flutter (stable)
- PostgreSQL
- Redis
- Playwright browsers
- Android Studio + AVD (for Android preview)

## Backend Setup

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
playwright install
```

Set env vars (PowerShell example):

```powershell
$env:DATABASE_URL="postgresql+psycopg2://postgres:postgres@localhost:5432/job_automation"
$env:JWT_SECRET_KEY="your-secret"
$env:REDIS_URL="redis://127.0.0.1:6379/0"
$env:OPENAI_API_KEY="your-openai-key"
$env:PLAYWRIGHT_HEADLESS="true"
$env:PLAYWRIGHT_TIMEOUT_MS="30000"
```

Run backend API:

```powershell
uvicorn app.main:app --reload
```

Run Celery worker:

```powershell
celery -A workers.worker.celery_app worker --loglevel=info
```

Run Celery beat scheduler:

```powershell
celery -A workers.worker.celery_app beat --loglevel=info
```

## Frontend Setup

```powershell
cd frontend
flutter pub get
```

Run web:

```powershell
flutter run -d chrome --dart-define=BASE_URL=http://127.0.0.1:8000
```

Run Android (AVD):

```powershell
flutter run -d android --dart-define=BASE_URL=http://10.0.2.2:8000
```

## Core API Endpoints

- `POST /auth/signup`
- `POST /auth/login`
- `GET /users/me`
- `POST /users/profile`
- `PUT /users/profile`
- `POST /resume/upload`
- `GET /jobs`
- `GET /jobs/matched`
- `POST /ai/generate-cover-letter`
- `POST /applications/apply`
- `POST /applications/auto-apply`
- `POST /applications/auto-apply-batch`
- `GET /applications`
- `GET /health`

## Notes

- For Android emulator, use `10.0.2.2` to reach local backend.
- Ensure PostgreSQL and Redis are running before launching workers.
- Job scraping and auto-apply run asynchronously via Celery tasks.
