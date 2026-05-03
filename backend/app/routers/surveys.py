from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.database import get_db
from app.models.user import User
from app.models.survey import Survey
from app.models.question import Question
from app.models.response import Response
from app.schemas.survey import SurveyCreate, SurveyUpdate, SurveyResponse, QuestionCreate
from app.services.auth_service import get_current_user

router = APIRouter(prefix="/api/surveys", tags=["surveys"])


@router.get("", response_model=List[SurveyResponse])
def get_my_surveys(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    surveys = db.query(Survey).filter(Survey.owner_id == current_user.id).all()
    result = []
    for s in surveys:
        survey_dict = {
            "id": s.id,
            "owner_id": s.owner_id,
            "title": s.title,
            "description": s.description,
            "access_type": s.access_type,
            "is_active": s.is_active,
            "created_at": s.created_at,
            "updated_at": s.updated_at,
            "questions": [
                {
                    "id": q.id,
                    "text": q.text,
                    "question_type": q.question_type,
                    "options": q.options,
                    "is_required": q.is_required,
                    "order": q.order,
                }
                for q in sorted(s.questions, key=lambda x: x.order)
            ],
            "response_count": db.query(Response).filter(Response.survey_id == s.id).count(),
        }
        result.append(survey_dict)
    return result


@router.post("", response_model=SurveyResponse, status_code=status.HTTP_201_CREATED)
def create_survey(survey_data: SurveyCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = Survey(
        owner_id=current_user.id,
        title=survey_data.title,
        description=survey_data.description,
        access_type=survey_data.access_type,
    )
    db.add(survey)
    db.flush()

    for i, q in enumerate(survey_data.questions):
        question = Question(
            survey_id=survey.id,
            text=q.text,
            question_type=q.question_type,
            options=q.options,
            is_required=q.is_required,
            order=i,
        )
        db.add(question)

    db.commit()
    db.refresh(survey)
    return get_survey_detail(survey, db)


@router.get("/{survey_id}", response_model=SurveyResponse)
def get_survey(survey_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.owner_id == current_user.id).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    return get_survey_detail(survey, db)


@router.put("/{survey_id}", response_model=SurveyResponse)
def update_survey(survey_id: int, survey_data: SurveyUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.owner_id == current_user.id).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")

    response_count = db.query(Response).filter(Response.survey_id == survey_id).count()
    has_responses = response_count > 0

    if survey_data.title is not None:
        survey.title = survey_data.title
    if survey_data.description is not None:
        survey.description = survey_data.description
    if survey_data.access_type is not None:
        survey.access_type = survey_data.access_type
    if survey_data.questions is not None:
        if has_responses:
            db.query(Response).filter(Response.survey_id == survey_id).delete()
        db.query(Question).filter(Question.survey_id == survey_id).delete()
        db.flush()
        for i, q in enumerate(survey_data.questions):
            question = Question(
                survey_id=survey.id,
                text=q.text,
                question_type=q.question_type,
                options=q.options,
                is_required=q.is_required,
                order=i,
            )
            db.add(question)

    db.commit()
    db.refresh(survey)
    return get_survey_detail(survey, db)


@router.delete("/{survey_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_survey(survey_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.owner_id == current_user.id).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    db.delete(survey)
    db.commit()


@router.post("/{survey_id}/publish", response_model=SurveyResponse)
def publish_survey(survey_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.owner_id == current_user.id).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    if not survey.questions:
        raise HTTPException(status_code=400, detail="Survey must have at least one question")
    survey.is_active = True
    db.commit()
    db.refresh(survey)
    return get_survey_detail(survey, db)


def get_survey_detail(survey: Survey, db: Session) -> dict:
    return {
        "id": survey.id,
        "owner_id": survey.owner_id,
        "title": survey.title,
        "description": survey.description,
        "access_type": survey.access_type,
        "is_active": survey.is_active,
        "created_at": survey.created_at,
        "updated_at": survey.updated_at,
        "questions": [
            {
                "id": q.id,
                "text": q.text,
                "question_type": q.question_type,
                "options": q.options,
                "is_required": q.is_required,
                "order": q.order,
            }
            for q in sorted(survey.questions, key=lambda x: x.order)
        ],
        "response_count": db.query(Response).filter(Response.survey_id == survey.id).count(),
    }
