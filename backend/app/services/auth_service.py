from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.user import User
from app.utils.security import hash_password, verify_password


def create_user(db: Session, email: str, password: str) -> User:
    existing_user = db.query(User).filter(User.email == email.lower()).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    user = User(email=email.lower(), password_hash=hash_password(password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, email: str, password: str) -> User:
    user = db.query(User).filter(User.email == email.lower()).first()
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
    return user
