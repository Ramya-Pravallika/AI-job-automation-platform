from fastapi import HTTPException, status
from openai import OpenAI

from app.config import settings


def _client() -> OpenAI:
    if not settings.OPENAI_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="OPENAI_API_KEY is not configured",
        )
    return OpenAI(api_key=settings.OPENAI_API_KEY)


def generate_embeddings(texts: list[str]) -> list[list[float]]:
    sanitized = [text if text.strip() else "No content" for text in texts]
    response = _client().embeddings.create(model=settings.OPENAI_EMBEDDING_MODEL, input=sanitized)
    return [item.embedding for item in response.data]


def generate_cover_letter(resume_text: str, job_description: str) -> str:
    prompt = (
        "Resume:\n"
        f"{resume_text}\n\n"
        "Job Description:\n"
        f"{job_description}\n\n"
        "Instruction:\n"
        "Write a tailored professional cover letter for this job."
    )

    completion = _client().chat.completions.create(
        model=settings.OPENAI_CHAT_MODEL,
        messages=[
            {
                "role": "system",
                "content": "You are an expert career assistant who writes concise, job-specific cover letters.",
            },
            {"role": "user", "content": prompt},
        ],
        temperature=0.4,
    )

    content = completion.choices[0].message.content
    return content.strip() if content else ""
