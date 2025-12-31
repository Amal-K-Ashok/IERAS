from fastapi import APIRouter, HTTPException
from app.schemas.case import CaseRequest, CaseResponse

router = APIRouter(
    prefix="/hospital",
    tags=["Hospital Case Handling"]
)

# Temporary in-memory storage for testing
cases_db = {}

@router.post("/receive-case")
def receive_case(case: CaseRequest):
    case_id = case.case_id
    cases_db[case_id] = {
        "case": case,
        "status": "PENDING"
    }
    return {"message": "Case received successfully!", "case_id": case_id}

@router.post("/accept/{case_id}")
def accept_case(case_id: str):
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")

    cases_db[case_id]["status"] = "ACCEPTED"
    return {"message": "Case accepted", "case_id": case_id}

@router.post("/reject/{case_id}")
def reject_case(case_id: str):
    if case_id not in cases_db:
        raise HTTPException(status_code=404, detail="Case not found")

    cases_db[case_id]["status"] = "REJECTED"
    return {"message": "Case rejected & ambulance notified!", "case_id": case_id}
