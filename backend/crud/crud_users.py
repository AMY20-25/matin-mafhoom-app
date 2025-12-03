from sqlalchemy.orm import Session
from fastapi import HTTPException
import random
from datetime import datetime, timedelta, timezone
from services import sms_service
from models import User, OtpCode
from schemas import UserRegister, UserUpdate

def get_user_by_phone(db: Session, phone: str):
    """Retrieves a user by their phone number."""
    return db.query(User).filter(User.phone_number == phone).first()

def get_user_by_id(db: Session, user_id: int):
    """Retrieves a user by their ID."""
    return db.query(User).filter(User.id == user_id).first()

def get_all_users(db: Session):
    """Retrieves all users."""
    return db.query(User).all()

def create_user(db: Session, data: UserRegister):
    """Creates a new user record."""
    existing_user = get_user_by_phone(db, phone=data.phone_number)
    if existing_user:
        raise HTTPException(status_code=400, detail="User with this phone number already exists")
    
    new_user = User(
        phone_number=data.phone_number,
        first_name=data.first_name,
        last_name=data.last_name,
        role="customer",
        is_active=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def create_and_send_otp(db: Session, phone: str):
    code = str(random.randint(100000, 999999))
    # Use naive datetime, which will be interpreted as Asia/Tehran by the DB
    now = datetime.now()
    expires_at = now + timedelta(minutes=3)
    
     # --- For Production: Enable real SMS sending ---
    message = f"کد ورود شما به سالن متین مفهوم: {code}\nلغو11"
    sms_service.send_sms(phone_number=phone, message=message) # <--- فعال شد
    #print(f"--- OTP for {phone} is {code} ---")
    db.query(OtpCode).filter(OtpCode.phone_number == phone).delete()
    otp_record = OtpCode(
        phone_number=phone,
        code=code,
        expires_at=expires_at,
        created_at=now
    )
    db.add(otp_record)
    db.commit()
    return otp_record

def verify_otp(db: Session, phone: str, code: str):
    """Verifies the OTP and creates a user if they don't exist."""
    otp = db.query(OtpCode).filter(
        OtpCode.phone_number == phone, 
        OtpCode.code == code
    ).order_by(OtpCode.id.desc()).first()
    
    # --- THE FINAL, CORRECT FIX ---
    # We now use datetime.now() which is NAIVE, just like the data from the DB
    if not otp or otp.expires_at < datetime.now():
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    user = get_user_by_phone(db, phone=phone)
    
    if not user:
        # We also need to fix the user creation to use naive datetime
        user = User(
            phone_number=phone, 
            role="customer", 
            is_active=True,
            created_at=datetime.now() # Use naive datetime here as well
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        
    return user


def update_user(db: Session, user_id: int, data: UserUpdate):
    """Updates a user's profile and checks for first-time completion."""
    user = get_user_by_id(db, user_id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    is_first_profile_completion = (not user.first_name and not user.last_name) and \
                                  (data.first_name is not None and data.last_name is not None)
    
    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user, key, value)
    db.commit()
    db.refresh(user)
    return {"user": user, "send_welcome_sms": is_first_profile_completion}

