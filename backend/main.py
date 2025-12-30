from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr
import os

app = FastAPI()

# -----------------------------
# CORS
# -----------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Static files
# -----------------------------
UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# -----------------------------
# In-memory storage (TEMP)
# -----------------------------
users = {}        # email → password
accidents = []    # accident list

# -----------------------------
# Models
# -----------------------------
class User(BaseModel):
    email: EmailStr
    password: str

class ResetPassword(BaseModel):
    email: EmailStr
    old_password: str
    new_password: str

# -----------------------------
# Auth APIs
# -----------------------------
@app.post("/register")
def register(user: User):
    if user.email in users:
        raise HTTPException(status_code=400, detail="User already exists")
    users[user.email] = user.password
    return {"message": "Registered successfully"}

@app.post("/login")
def login(user: User):
    if users.get(user.email) != user.password:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {
        "id": user.email.split("@")[0],
        "name": user.email.split("@")[0],
        "email": user.email
    }

@app.put("/reset-password")
def reset_password(data: ResetPassword):
    if data.email not in users:
        raise HTTPException(status_code=404, detail="User not found")
    if users[data.email] != data.old_password:
        raise HTTPException(status_code=401, detail="Old password incorrect")

    users[data.email] = data.new_password
    return {"message": "Password updated"}

# -----------------------------
# Accident APIs
# -----------------------------
@app.post("/accident")
async def submit_accident(
    location: str = Form(...),
    timestamp: str = Form(...),
    image: UploadFile = File(...)
):
    image_path = f"{UPLOAD_DIR}/{image.filename}"
    with open(image_path, "wb") as f:
        f.write(await image.read())

    accident = {
        "id": len(accidents) + 1,
        "location": location,
        "timestamp": timestamp,
        "image": image_path,
        "status": "Pending"
    }

    accidents.append(accident)
    return {"message": "Accident report stored successfully"}

@app.get("/accidents")
def get_accidents():
    return accidents
