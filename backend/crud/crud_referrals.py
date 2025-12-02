from sqlalchemy.orm import Session
from fastapi import HTTPException
import random
import string

# Import other CRUD modules to use their functions
from . import crud_discounts
from models import Referral, User
from schemas import DiscountCreate

# -------------------------------
# Generate referral code
# -------------------------------
def generate_referral_code():
    """Generates a random 8-character alphanumeric code."""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

# -------------------------------
# Create or get a referral profile for a user
# -------------------------------
def create_referral_profile(db: Session, user_id: int):
    """
    Gets the referral profile for a user. If it doesn't exist, creates one.
    This is now the primary function to get referral info.
    """
    existing_profile = db.query(Referral).filter(Referral.user_id == user_id).first()
    if existing_profile:
        return existing_profile

    new_code = generate_referral_code()
    while db.query(Referral).filter(Referral.referral_code == new_code).first():
        new_code = generate_referral_code() # Ensure code is unique

    new_profile = Referral(
        user_id=user_id,
        referral_code=new_code,
        invited_count=0,
    )
    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)
    return new_profile

# -------------------------------
# Handle when a user applies a referral code
# -------------------------------
def apply_referral_code(db: Session, applying_user_id: int, code: str):
    """
    Handles the logic when a user applies a referral code.
    It increments the inviter's count and creates a discount if the threshold is met.
    """
    # 1. Find the inviter by their referral code
    inviter_profile = db.query(Referral).filter(Referral.referral_code == code).first()
    if not inviter_profile:
        raise HTTPException(status_code=404, detail="Invalid referral code")

    # 2. Prevent a user from using their own code
    if inviter_profile.user_id == applying_user_id:
        raise HTTPException(status_code=400, detail="Cannot use your own referral code")

    # 3. Increment the inviter's count
    inviter_profile.invited_count += 1
    
    # 4. Check if the threshold is met (e.g., 5 invites)
    if inviter_profile.invited_count >= 5:
        # Create a special discount for the inviter
        discount_data = DiscountCreate(
            user_id=inviter_profile.user_id,
            discount_type="referral_bonus",
            percentage=20, # Example: 20% discount
        )
        crud_discounts.create_discount(db, data=discount_data)
        
        # Reset the counter
        inviter_profile.invited_count = 0
        
        db.commit()
        return {"message": "Referral applied! A 20% discount has been awarded to the inviter."}

    db.commit()
    return {"message": "Referral applied successfully. Progress tracked."}
