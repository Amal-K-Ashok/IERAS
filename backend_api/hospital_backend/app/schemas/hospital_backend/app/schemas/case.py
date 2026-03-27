from pydantic import BaseModel

class CaseRequest(BaseModel):
    case_id: str
    ambulance_id: str
    patient_condition: str
    severity: str
    location: str

class CaseResponse(BaseModel):
    case_id: str
    status: str
