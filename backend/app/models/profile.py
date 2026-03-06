from sqlalchemy import ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Profile(Base):
    __tablename__ = "profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), unique=True)
    skills: Mapped[str | None] = mapped_column(String, nullable=True)
    experience: Mapped[str | None] = mapped_column(String, nullable=True)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    preferred_roles: Mapped[str | None] = mapped_column(String, nullable=True)
    remote_preference: Mapped[str | None] = mapped_column(String(50), nullable=True)

    user = relationship("User", back_populates="profile")
