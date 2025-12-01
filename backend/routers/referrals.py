from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from crud.crud_referrals import (
    create_referral as crud_create_referral,
    get_user_referrals
)
from schemas import ReferralCreate, ReferralResponse

router = APIRouter(prefix="/referrals", tags=["Referrals"])


# =====================================================
# Create a referral (inviter invites someone)
# =====================================================
@router.post("/", response_model=ReferralResponse)
def create_new_referral(data: ReferralCreate, db: Session = Depends(get_db)):
    try:
        return crud_create_referral(db, data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# Get referrals sent by a specific user
# =====================================================
@router.get("/user/{user_id}", response_model=list[ReferralResponse])
def list_user_referrals(user_id: int, db: Session = Depends(get_db)):
    return get_user_referrals(db, user_id)

