from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session
from typing import List

# Import dependencies and models
from database import get_db
from models import User
from crud import crud_referrals
from schemas import ReferralResponse 
from auth import get_current_user

router = APIRouter(prefix="/referrals", tags=["Referrals"])

# We need a Pydantic model for the response, inheriting from the base
class ReferralInfo(ReferralResponse):
    pass # ReferralResponse already has all the fields we need

@router.get("/me", response_model=ReferralInfo)
def read_my_referral_profile(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return crud_referrals.create_referral_profile(db, user_id=current_user.id)

@router.post("/apply", status_code=status.HTTP_200_OK)
def apply_referral_code(
    code: str = Body(..., embed=True), 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    try:
        return crud_referrals.apply_referral_code(db, applying_user_id=current_user.id, code=code)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")
