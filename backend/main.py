# main.py — Matin Mafhoom Backend (optimized simple version)

from dotenv import load_dotenv
load_dotenv(dotenv_path=".env")

import os
import time
import io
import base64
import random
import logging
from datetime import datetime
from typing import Optional

from fastapi import FastAPI, Depends, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.concurrency import run_in_threadpool
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

import cv2
import numpy as np
import torch
from PIL import Image
import torchvision.transforms as transforms

# Database + Models
from database import get_db, SessionLocal
import models

# Routers
from routers import users as users_router
from routers import reservations as reservations_router
from routers import payments as payments_router
from routers import discounts as discounts_router
from routers import referrals as referrals_router

# ----------------------------------------------------------
# FastAPI Initialization
# ----------------------------------------------------------
app = FastAPI(
    title="Matin Mafhoom Backend",
    version="1.0.1",
    description="Backend API for Matin Mafhoom Grooming Salon"
)

# ----------------------------------------------------------
# CORS
# ----------------------------------------------------------
origins = os.getenv("CORS_ORIGINS", "*")
allow_origins = ["*"] if origins == "*" else [o.strip() for o in origins.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------------------------------------------------
# Include Routers
# ----------------------------------------------------------
app.include_router(users_router.router, prefix="/api/v1")
app.include_router(reservations_router.router, prefix="/api/v1")
app.include_router(payments_router.router, prefix="/api/v1")
app.include_router(discounts_router.router, prefix="/api/v1")
app.include_router(referrals_router.router, prefix="/api/v1")

# ----------------------------------------------------------
# Config / Secrets
# ----------------------------------------------------------
SECRET_KEY = os.getenv("JWT_SECRET", "supersecretkey")
ALGORITHM = os.getenv("JWT_ALGO", "HS256")
OTP_EXP_SECONDS = int(os.getenv("OTP_EXPIRE_MIN", "3")) * 60

SMS_USERNAME = os.getenv("SMS_USERNAME")
SMS_PASSWORD = os.getenv("SMS_PASSWORD")
SMS_API_URL = os.getenv("SMS_API_URL", "https://rest.payamak-panel.com/api/SendSMS/SendSMS")
SMS_SENDER = os.getenv("SMS_FROM")

otp_store: dict = {}

# ----------------------------------------------------------
# Pydantic Local Models
# ----------------------------------------------------------
class RequestOTP(BaseModel):
    phone_number: str = Field(..., min_length=10, max_length=15)

class VerifyOTP(BaseModel):
    phone_number: str = Field(..., min_length=10, max_length=15)
    otp: str = Field(..., min_length=4, max_length=6)

class SimpleUserOut(BaseModel):
    id: int
    full_name: Optional[str] = None
    phone: str

    class Config:
        from_attributes = True

# ----------------------------------------------------------
# Health Check
# ----------------------------------------------------------
@app.get("/health")
def health_check():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}

# ----------------------------------------------------------
# OTP / AUTH
# ----------------------------------------------------------
@app.post("/auth/request_otp")
def request_otp(data: RequestOTP):
    phone = data.phone_number
    otp = f"{random.randint(1000, 9999)}"
    otp_store[phone] = {"otp": otp, "timestamp": time.time()}

    message = f"کد ورود شما به سالن متین مفهوم:\n{otp}"

    payload = {
        "username": SMS_USERNAME,
        "password": SMS_PASSWORD,
        "to": phone,
        "from": SMS_SENDER,
        "text": message,
        "isflash": False
    }

    try:
        import requests
        resp = requests.post(SMS_API_URL, json=payload, timeout=8)
        if resp.status_code != 200:
            return {"message": "OTP generated but SMS not confirmed (dev mode)"}
    except:
        return {"message": "OTP generated (SMS service unreachable)"}

    return {"message": "OTP sent"}

@app.post("/auth/verify_otp")
def verify_otp(data: VerifyOTP, db: Session = Depends(get_db)):
    phone = data.phone_number

    if phone not in otp_store:
        raise HTTPException(status_code=400, detail="OTP not requested")

    record = otp_store[phone]

    if time.time() - record["timestamp"] > OTP_EXP_SECONDS:
        del otp_store[phone]
        raise HTTPException(status_code=400, detail="OTP expired")

    if record["otp"] != data.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    user = db.query(models.User).filter(models.User.phone == phone).first()
    if not user:
        user = models.User(
            phone=phone,
            created_at=datetime.utcnow()
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    import jwt
    token = jwt.encode(
        {"user_id": user.id, "phone": phone, "exp": int(time.time()) + 3600},
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    del otp_store[phone]

    return {"access_token": token, "token_type": "bearer", "user": SimpleUserOut.model_validate(user)}

# ----------------------------------------------------------
# AI Section (Simplified)
# ----------------------------------------------------------
insight_app = None
gfpganer = None
bisenet = None
AI_LOAD_ERRORS = []

bisenet_transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.485, 0.456, 0.406), (0.229, 0.224, 0.225)),
])

def load_ai_models():
    global insight_app, gfpganer, bisenet, AI_LOAD_ERRORS
    AI_LOAD_ERRORS = []

    try:
        import insightface
        insight_app = insightface.app.FaceAnalysis(
            name="buffalo_l",
            root="ai_models/insightface"
        )
        insight_app.prepare(ctx_id=0)
    except Exception as e:
        insight_app = None
        AI_LOAD_ERRORS.append(f"InsightFace: {e}")

    try:
        from gfpgan import GFPGANer
        gfpganer = GFPGANer(
            model_path="ai_models/gfpgan/GFPGANv1.4.pth",
            upscale=2,
            arch="clean",
            channel_multiplier=2
        )
    except Exception as e:
        gfpganer = None
        AI_LOAD_ERRORS.append(f"GFPGAN: {e}")

    try:
        from facexlib.parsing.bisenet import BiSeNet
        bisenet = BiSeNet(19)
        bisenet.load_state_dict(torch.load("ai_models/face_parsing/BiSeNet.pth", map_location="cpu"))
        bisenet.eval()
    except Exception as e:
        bisenet = None
        AI_LOAD_ERRORS.append(f"BiSeNet: {e}")

def ensure_ai(which):
    if which == "insight" and insight_app is None:
        raise HTTPException(status_code=503, detail="InsightFace unavailable")
    if which == "gfpgan" and gfpganer is None:
        raise HTTPException(status_code=503, detail="GFPGAN unavailable")
    if which == "bisenet" and bisenet is None:
        raise HTTPException(status_code=503, detail="BiSeNet unavailable")

@app.on_event("startup")
async def startup_event():
    try:
        models.Base.metadata.create_all(bind=SessionLocal().get_bind())
    except Exception as e:
        print("DB init error:", e)

    try:
        await run_in_threadpool(load_ai_models)
    except:
        pass

# ----------------------------------------------------------
# AI Endpoints
# ----------------------------------------------------------
@app.post("/ai/insightface")
async def ai_insight(file: UploadFile = File(...)):
    ensure_ai("insight")
    img_bytes = await file.read()
    img = cv2.imdecode(np.frombuffer(img_bytes, np.uint8), cv2.IMREAD_COLOR)
    faces = insight_app.get(img)
    return {"faces_detected": len(faces)}

@app.on_event("shutdown")
def shutdown_event():
    print("Backend shutting down...")

# ----------------------------------------------------------
# END
# ----------------------------------------------------------

