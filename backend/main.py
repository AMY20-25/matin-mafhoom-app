# main.py — Matin Mafhoom Backend (Refactored - No AI)
from dotenv import load_dotenv
load_dotenv() # Load environment variables from .env file

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

# Import all active routers
from routers import users, reservations, payments, discounts, referrals, auth
from database import Base, engine

# Create all database tables on startup if they don't exist
Base.metadata.create_all(bind=engine)

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Matin Mafhoom Backend",
    version="1.5.0", # Version updated
    description="Backend API for Matin Mafhoom Grooming Salon (AI module deferred)"
)

# --- CORS Configuration ---
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080,https://matinmafhoom.ir")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins.split(','),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Include All Routers ---
app.include_router(auth.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(reservations.router, prefix="/api/v1")
app.include_router(payments.router, prefix="/api/v1")
app.include_router(discounts.router, prefix="/api/v1")
app.include_router(referrals.router, prefix="/api/v1")

# --- Health Check Endpoint ---
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok"}

@app.on_event("startup")
async def startup_event():
    print("Backend starting up...")

@app.on_event("shutdown")
def shutdown_event():
    print("Backend shutting down.")
