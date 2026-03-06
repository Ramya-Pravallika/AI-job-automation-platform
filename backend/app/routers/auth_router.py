from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.user_schema import TokenResponse, UserLoginRequest, UserSignupRequest
from app.services.auth_service import authenticate_user, create_user
from app.utils.security import create_access_token


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def signup(payload: UserSignupRequest, db: Session = Depends(get_db)) -> TokenResponse:
    user = create_user(db=db, email=payload.email, password=payload.password)
    token = create_access_token(subject=str(user.id))
    return TokenResponse(access_token=token)


@router.post("/login", response_model=TokenResponse)
def login(payload: UserLoginRequest, db: Session = Depends(get_db)) -> TokenResponse:
    user = authenticate_user(db=db, email=payload.email, password=payload.password)
    token = create_access_token(subject=str(user.id))
    return TokenResponse(access_token=token)
