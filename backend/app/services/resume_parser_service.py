import re
from pathlib import Path

from docx import Document
from pdfminer.high_level import extract_text as extract_pdf_text


COMMON_SKILLS = {
    "python",
    "java",
    "javascript",
    "typescript",
    "sql",
    "postgresql",
    "mysql",
    "mongodb",
    "redis",
    "fastapi",
    "django",
    "flask",
    "react",
    "node",
    "aws",
    "docker",
    "kubernetes",
    "git",
    "linux",
    "machine learning",
    "pandas",
    "numpy",
    "scikit-learn",
    "tensorflow",
    "pytorch",
    "celery",
    "playwright",
}


def extract_text_from_pdf(file_path: Path) -> str:
    return extract_pdf_text(str(file_path)).strip()


def extract_text_from_docx(file_path: Path) -> str:
    doc = Document(str(file_path))
    return "\n".join(paragraph.text for paragraph in doc.paragraphs).strip()


def extract_resume_text(file_path: Path, file_type: str) -> str:
    extension = file_type.lower().strip(".")
    if extension == "pdf":
        return extract_text_from_pdf(file_path)
    if extension == "docx":
        return extract_text_from_docx(file_path)
    raise ValueError("Unsupported resume format. Please upload PDF or DOCX.")


def extract_skills(parsed_text: str) -> list[str]:
    lowered = parsed_text.lower()
    found = [skill for skill in COMMON_SKILLS if skill in lowered]
    return sorted(set(found))


def extract_experience_summary(parsed_text: str) -> str | None:
    pattern = re.compile(r"(\d+\+?\s+years?)", flags=re.IGNORECASE)
    match = pattern.search(parsed_text)
    if not match:
        return None
    return match.group(1)


def parse_resume(file_path: Path, file_type: str) -> dict:
    parsed_text = extract_resume_text(file_path=file_path, file_type=file_type)
    return {
        "parsed_text": parsed_text,
        "skills_extracted": extract_skills(parsed_text),
        "experience_summary": extract_experience_summary(parsed_text),
    }
