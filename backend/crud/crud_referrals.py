from sqlalchemy.orm import Session
from fastapi import HTTPException
from models import Referral, User
from schemas import ReferralCreate

def create_referral(db: Session, referral: ReferralCreate, inviter_user: User):
    invited_user = db.query(User).filter(User.id == referral.invited_user_id).first()
    if not invited_user:
        raise HTTPException(status_code=404, detail="Invited user not found.")
    if inviter_user.phone_number == invited_user.phone_number:
        raise HTTPException(status_code=400, detail="Users cannot refer themselves.")
    
    db_referral = Referral(
        user_id=invited_user.id,
        invited_phone=inviter_user.phone_number, # Corrected field
        used=False
    )
    db.add(db_referral)
    db.commit()
    db.refresh(db_referral)
    return db_referral

def get_referrals_by_user(db: Session, user_phone: str):
    # Now we get referrals based on the inviter's phone number
    return db.query(Referral).filter(Referral.invited_phone == user_phone).all()

