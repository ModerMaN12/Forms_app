from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.database import Base


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    survey_id = Column(Integer, ForeignKey("surveys.id"), nullable=False)
    text = Column(String(500), nullable=False)
    question_type = Column(String(30), nullable=False)
    options = Column(JSON, nullable=True)
    is_required = Column(Boolean, default=True)
    order = Column(Integer, default=0)

    survey = relationship("Survey", back_populates="questions")
    answers = relationship("Answer", back_populates="question", cascade="all, delete-orphan")
