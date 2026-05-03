from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class QuestionCreate(BaseModel):
    text: str
    question_type: str
    options: Optional[List[str]] = None
    is_required: bool = True
    order: int = 0


class QuestionResponse(BaseModel):
    id: int
    text: str
    question_type: str
    options: Optional[List[str]] = None
    is_required: bool
    order: int

    class Config:
        from_attributes = True


class SurveyCreate(BaseModel):
    title: str
    description: str = ""
    access_type: str = "anonymous"
    questions: List[QuestionCreate] = []


class SurveyUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    access_type: Optional[str] = None
    questions: Optional[List[QuestionCreate]] = None


class SurveyResponse(BaseModel):
    id: int
    owner_id: int
    title: str
    description: str
    access_type: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    questions: List[QuestionResponse] = []
    response_count: int = 0

    class Config:
        from_attributes = True
