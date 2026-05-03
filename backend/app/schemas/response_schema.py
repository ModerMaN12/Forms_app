from pydantic import BaseModel
from typing import List, Optional, Any
from datetime import datetime


class AnswerInput(BaseModel):
    question_id: int
    value: Any


class SubmitResponse(BaseModel):
    respondent_name: Optional[str] = None
    respondent_email: Optional[str] = None
    answers: List[AnswerInput]


class AnswerStats(BaseModel):
    question_id: int
    question_text: str
    question_type: str
    total_answers: int
    text_answers: List[str] = []
    choice_counts: dict = {}
    rating_avg: Optional[float] = None
    rating_distribution: dict = {}


class ResultsResponse(BaseModel):
    survey_id: int
    survey_title: str
    total_responses: int
    question_stats: List[AnswerStats]
    recent_responses: List[dict] = []
