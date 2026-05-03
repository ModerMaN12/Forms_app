from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
from app.database import Base


class Response(Base):
    __tablename__ = "responses"

    id = Column(Integer, primary_key=True, index=True)
    survey_id = Column(Integer, ForeignKey("surveys.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    respondent_email = Column(String(255), nullable=True)
    respondent_name = Column(String(100), nullable=True)
    submitted_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    survey = relationship("Survey", back_populates="responses")
    user = relationship("User", foreign_keys=[user_id])
    answers = relationship("Answer", back_populates="response", cascade="all, delete-orphan")


class Answer(Base):
    __tablename__ = "answers"

    id = Column(Integer, primary_key=True, index=True)
    response_id = Column(Integer, ForeignKey("responses.id"), nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    value = Column(JSON, nullable=False)

    response = relationship("Response", back_populates="answers")
    question = relationship("Question", back_populates="answers")
