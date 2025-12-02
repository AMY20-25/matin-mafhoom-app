import os
import requests
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from crud import crud_users
from schemas import UserRegister, UserOut, UserUpdate
from models import User
from auth import get_current_user, get_current_admin_user

router = APIRouter(prefix="/users", tags=["Users"])

@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def create_new_user(data: UserRegister, db: Session = Depends(get_db)):
    """
    Creates a new user. The check for existing user is handled in the CRUD function.
    """
    return crud_users.create_user(db, data=data)

@router.patch("/me", response_model=UserOut)
def update_current_user(data: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Updates the current authenticated user's profile.
    Triggers a webhook on first profile completion.
    """
    result = crud_users.update_user(db, user_id=current_user.id, data=data)
    updated_user = result["user"]
    
    if result["send_welcome_sms"]:
        webhook_url = os.getenv("N8N_WELCOME_SMS_WEBHOOK")
        if webhook_url:
            try:
                requests.post(webhook_url, json={
                    "phone_number": updated_user.phone_number,
                    "first_name": updated_user.first_name,
                    "last_name": updated_user.last_name
                }, timeout=5)
            except requests.RequestException as e:
                print(f"ERROR: Could not call n8n webhook: {e}")

    return updated_user

# Note: The /users/me endpoint is now in routers/auth.py for better consistency.

# --- ADMIN ONLY ROUTES ---

@router.get("/", response_model=List[UserOut], dependencies=[Depends(get_current_admin_user)])
def list_all_users_admin(db: Session = Depends(get_db)):
    """
    Retrieves a list of all users. (Admin only)
    """
    return crud_users.get_all_users(db)

@router.get("/{user_id}", response_model=UserOut, dependencies=[Depends(get_current_admin_user)])
def get_user_by_id_admin(user_id: int, db: Session = Depends(get_db)):
    """
    Retrieves a single user by ID. (Admin only)
    """
    user = crud_users.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

