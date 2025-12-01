# main.py — Matin Mafhoom Backend (Refactored)
from dotenv import load_dotenv
load_dotenv() # Load environment variables from .env file

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os

# Import all routers
from routers import users, reservations, payments, discounts, referrals, auth
# We will create the AI router later
# from routers import ai 

from database import Base, engine

# Create all database tables on startup if they don't exist
# Note: In production, you would typically use Alembic for migrations.
Base.metadata.create_all(bind=engine)

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Matin Mafhoom Backend",
    version="2.0.0",
    description="Refactored backend API for Matin Mafhoom Grooming Salon"
)

# --- CORS Configuration ---
# It's better to be specific with origins in production
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins.split(','),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Include All Routers ---
# All application logic is now modularized in routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(reservations.router, prefix="/api/v1")
app.include_router(payments.router, prefix="/api/v1")
app.include_router(discounts.router, prefix="/api/v1")
app.include_router(referrals.router, prefix="/api/v1")
# app.include_router(ai.router, prefix="/api/v1")

# --- Health Check Endpoint ---
@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok"}

# --- AI Model Loading (Simplified for now) ---
# In a real-world scenario, this logic would also move to its own module.
@app.on_event("startup")
async def startup_event():
    print("Backend starting up...")
    # AI models would be loaded here
    print("AI models would be loaded in a background thread here.")

@app.on_event("shutdown")
def shutdown_event():
    print("Backend shutting down.")
