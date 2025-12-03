from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import User
from crud import crud_referrals
from schemas import ReferralCreate, ReferralResponse
from auth import get_current_user

router = APIRouter(prefix="/referrals", tags=["Referrals"])

@router.post("/", response_model=ReferralResponse)
def create_new_referral(referral_data: ReferralCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return crud_referrals.create_referral(db, referral=referral_data, inviter_user=current_user)

@router.get("/me", response_model=List[ReferralResponse])
def read_my_sent_referrals(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    # We now pass the user's phone number to the CRUD function
    return crud_referrals.get_referrals_by_user(db, user_phone=current_user.phone_number)

