from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class UserSignupRequest(BaseModel):
    email: str = Field(
        min_length=5,
        max_length=255,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )
    password: str = Field(min_length=8, max_length=128)


class UserLoginRequest(BaseModel):
    email: str = Field(
        min_length=5,
        max_length=255,
        pattern=r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
    )
    password: str = Field(min_length=8, max_length=128)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class ProfileBase(BaseModel):
    skills: str | None = None
    experience: str | None = None
    location: str | None = None
    preferred_roles: str | None = None
    remote_preference: str | None = None


class ProfileCreateRequest(ProfileBase):
    pass


class ProfileUpdateRequest(ProfileBase):
    pass


class ProfileResponse(ProfileBase):
    id: int
    user_id: int

    model_config = ConfigDict(from_attributes=True)


class UserMeResponse(BaseModel):
    id: int
    email: str
    created_at: datetime
    profile: ProfileResponse | None

    model_config = ConfigDict(from_attributes=True)
