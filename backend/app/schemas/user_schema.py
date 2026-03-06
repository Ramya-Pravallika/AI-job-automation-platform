from datetime import datetime

from pydantic import BaseModel, ConfigDict


class UserSignupRequest(BaseModel):
    email: str
    password: str


class UserLoginRequest(BaseModel):
    email: str
    password: str


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
