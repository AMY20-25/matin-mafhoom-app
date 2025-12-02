from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field

from database import get_db
from crud import crud_users
from auth import create_access_token, get_current_user
from schemas import UserOut
from models import User # Import the User model

router = APIRouter(prefix="/auth", tags=["Authentication"])

class OTPRequest(BaseModel):
    phone_number: str = Field(..., pattern=r"^09[0-9]{9}$")

@router.post("/request-otp", status_code=status.HTTP_200_OK)
def request_otp_code(data: OTPRequest, db: Session = Depends(get_db)):
    """
    Generates and sends an OTP to the provided phone number.
    """
    crud_users.create_and_send_otp(db, phone=data.phone_number)
    return {"message": "OTP sent successfully"}

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """
    Verifies the OTP and returns a JWT access token upon success.
    """
    user = crud_users.verify_otp(db, phone=form_data.username, code=form_data.password)
    
    access_token = create_access_token(data={"sub": user.phone_number})
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserOut)
def read_users_me(current_user: User = Depends(get_current_user)):
    """
    Returns the profile of the currently authenticated user.
    """
    return current_user

