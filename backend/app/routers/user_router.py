from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.profile import Profile
from app.models.user import User
from app.schemas.user_schema import (
    ProfileCreateRequest,
    ProfileResponse,
    ProfileUpdateRequest,
    UserMeResponse,
)
from app.utils.security import get_current_user


router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserMeResponse)
def get_me(current_user: User = Depends(get_current_user)) -> UserMeResponse:
    return current_user


@router.post("/profile", response_model=ProfileResponse, status_code=status.HTTP_201_CREATED)
def create_profile(
    payload: ProfileCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProfileResponse:
    existing_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if existing_profile:
        for field, value in payload.model_dump().items():
            setattr(existing_profile, field, value)
        db.commit()
        db.refresh(existing_profile)
        return existing_profile

    profile = Profile(user_id=current_user.id, **payload.model_dump())
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


@router.put("/profile", response_model=ProfileResponse)
def update_profile(
    payload: ProfileUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> ProfileResponse:
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if profile is None:
        profile = Profile(user_id=current_user.id)
        db.add(profile)

    for field, value in payload.model_dump().items():
        setattr(profile, field, value)

    db.commit()
    db.refresh(profile)
    return profile
