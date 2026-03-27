from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import hospital_cases

app = FastAPI(
    title="Hospital Backend API",
    description="Handles hospital requests, ambulance tracking & referrals",
    version="1.0"
)

# Allow all frontend origins for now
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include the router
app.include_router(hospital_cases.router)

@app.get("/")
def root():
    return {"message": "Hospital backend running successfully!"}
