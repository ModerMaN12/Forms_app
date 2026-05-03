from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.survey import Survey
from app.services.html_generator import generate_survey_html

router = APIRouter(tags=["public"])


@router.get("/s/{survey_id}", response_class=HTMLResponse)
def public_survey_page(survey_id: int, request: Request, db: Session = Depends(get_db)):
    survey = db.query(Survey).filter(Survey.id == survey_id, Survey.is_active == True).first()
    if not survey:
        raise HTTPException(status_code=404, detail="Survey not found")
    html = generate_survey_html(survey)
    return HTMLResponse(content=html)
