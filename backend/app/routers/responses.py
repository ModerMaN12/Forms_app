from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import Optional
from collections import defaultdict
from app.database import get_db
from app.models.user import User
from app.models.survey import Survey
from app.models.response import Response, Answer
from app.schemas.response_schema import SubmitResponse, ResultsResponse, AnswerStats
from app.services.auth_service import get_current_user, oauth2_scheme
from jose import jwt, JWTError
from app.config import settings

router = APIRouter(prefix="/api/responses", tags=["responses"])


def get_optional_user(request: Request, db: Session) -> Optional[User]:
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return None
        token = auth_header.split(" ")[1]
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        email = payload.get("sub")
        if not email:
            return None
        return db.query(User).filter(User.email == email).first()
    except (JWTError, Exception):
        return None


@router.post("/{survey_id}", status_code=status.HTTP_201_CREATED)
def submit_response(survey_id: int, data: SubmitResponse, request: Request, db: Session = Depends(get_db)):
    survey = db.query(Survey).filter(Survey.id == survey_id).first()
    if not survey or not survey.is_active:
        raise HTTPException(status_code=404, detail="Survey not found or inactive")

    user = get_optional_user(request, db)

    if survey.access_type == "authenticated":
        if not user:
            raise HTTPException(status_code=401, detail="Authentication required for this survey")

    response_obj = Response(
        survey_id=survey_id,
        user_id=user.id if user else None,
        respondent_name=data.respondent_name,
        respondent_email=data.respondent_email,
    )
    db.add(response_obj)
    db.flush()

    question_ids = {q.id for q in survey.questions}
    for ans in data.answers:
        if ans.question_id not in question_ids:
            raise HTTPException(status_code=400, detail=f"Invalid question ID: {ans.question_id}")

        question = db.query(Question).filter(Question.id == ans.question_id).first()
        if question and question.is_required and not ans.value:
            raise HTTPException(status_code=400, detail=f"Question {ans.question_id} is required")

        answer = Answer(
            response_id=response_obj.id,
            question_id=ans.question_id,
            value=ans.value if isinstance(ans.value, list) else str(ans.value),
        )
        db.add(answer)

    db.commit()
    return {"message": "Response submitted", "response_id": response_obj.id}


@router.get("/{survey_id}/results", response_model=ResultsResponse)
def get_results(survey_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.owner_id == current_user.id).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")

    all_responses = db.query(Response).filter(Response.survey_id == survey_id).all()
    question_stats = []

    for question in survey.questions:
        answers = db.query(Answer).filter(Answer.question_id == question.id).all()

        stats = AnswerStats(
            question_id=question.id,
            question_text=question.text,
            question_type=question.question_type,
            total_answers=len(answers),
        )

        if question.question_type == "text":
            stats.text_answers = [str(a.value) for a in answers]
        elif question.question_type in ("single_choice", "multiple_choice"):
            counts = defaultdict(int)
            for a in answers:
                if isinstance(a.value, list):
                    for v in a.value:
                        counts[v] += 1
                else:
                    counts[str(a.value)] += 1
            stats.choice_counts = dict(counts)
        elif question.question_type in ("rating", "scale"):
            values = []
            dist = defaultdict(int)
            for a in answers:
                try:
                    val = int(a.value)
                    values.append(val)
                    dist[val] += 1
                except (ValueError, TypeError):
                    pass
            stats.rating_avg = round(sum(values) / len(values), 2) if values else None
            stats.rating_distribution = {str(k): v for k, v in sorted(dist.items())}

        question_stats.append(stats)

    recent = []
    for resp in sorted(all_responses, key=lambda r: r.submitted_at, reverse=True)[:10]:
        recent.append({
            "id": resp.id,
            "respondent_name": resp.respondent_name,
            "submitted_at": resp.submitted_at.isoformat() if resp.submitted_at else None,
        })

    return ResultsResponse(
        survey_id=survey.id,
        survey_title=survey.title,
        total_responses=len(all_responses),
        question_stats=question_stats,
        recent_responses=recent,
    )
