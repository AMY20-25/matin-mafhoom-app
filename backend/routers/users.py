import os
import requests
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Local Imports
from database import get_db
from crud import crud_users
from schemas import UserOut, UserUpdate
from models import User
from auth import get_current_user, get_current_admin_user

# --- Router Definition ---
router = APIRouter(
    prefix="/users", 
    tags=["Users"]
)

# --- Endpoints ---

@router.patch("/me", response_model=UserOut)
def update_current_user_profile(data: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Updates the profile of the currently authenticated user.
    Triggers a webhook on the first time a user sets their name and family name.
    """
    result = crud_users.update_user(db, user_id=current_user.id, data=data)
    updated_user = result["user"]
    
    # If the CRUD function signals a first-time completion, call the n8n webhook
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
                # Log the error but do not fail the main API request
                print(f"ERROR: Could not call n8n webhook: {e}")

    return updated_user


# --- ADMIN-ONLY Endpoints ---

@router.get("/", response_model=List[UserOut], dependencies=[Depends(get_current_admin_user)])
def read_all_users(db: Session = Depends(get_db)):
    """
    Retrieves a list of all users. Requires admin privileges.
    """
    return crud_users.get_all_users(db)


@router.get("/{user_id}", response_model=UserOut, dependencies=[Depends(get_current_admin_user)])
def read_user_by_id(user_id: int, db: Session = Depends(get_db)):
    """
    Retrieves a single user by their ID. Requires admin privileges.
    """
    user = crud_users.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

