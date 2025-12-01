from sqlalchemy.orm import Session
from fastapi import HTTPException
from models import Referral, User
from datetime import datetime
import random
import string


# -------------------------------
# Generate referral code
# -------------------------------
def generate_referral_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))


# -------------------------------
# Create referral record for a new user
# (This runs automatically after signup)
# -------------------------------
def create_referral_profile(db: Session, user_id: int):
    existing = db.query(Referral).filter(Referral.user_id == user_id).first()
    if existing:
        return existing

    code = generate_referral_code()

    referral = Referral(
        user_id=user_id,
        referral_code=code,
        invited_count=0,
    )

    db.add(referral)
    db.commit()
    db.refresh(referral)
    return referral


# -------------------------------
# Handle when a user enters referral code
# -------------------------------
def apply_referral_code(db: Session, user_id: int, code: str):

    # find inviter by referral_code
    inviter = db.query(Referral).filter(Referral.referral_code == code).first()
    if not inviter:
        raise HTTPException(status_code=404, detail="Invalid referral code")

    if inviter.user_id == user_id:
        raise HTTPException(status_code=400, detail="Cannot use your own referral code")

    # increase count
    inviter.invited_count += 1
    db.commit()

    return {"message": "Referral applied successfully"}
    

# -------------------------------
# Get user's referral info
# -------------------------------
def get_referral_info(db: Session, user_id: int):
    referral = db.query(Referral).filter(Referral.user_id == user_id).first()
    if not referral:
        raise HTTPException(status_code=404, detail="Referral profile not found")
    return referral

