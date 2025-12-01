from sqlalchemy.orm import Session
from fastapi import HTTPException
from models import User, OtpCode
from schemas import UserCreate, UserUpdate
from datetime import datetime, timedelta
import random


# -------------------------------------------------------------------
# 📌 Create User (Manual Signup)
# -------------------------------------------------------------------
def create_user(db: Session, data: UserCreate):
    existing = db.query(User).filter(User.phone == data.phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")

    new_user = User(
        phone=data.phone,
        full_name=data.full_name,
        role=data.role or "user"
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# -------------------------------------------------------------------
# 📌 Create OTP Code
# -------------------------------------------------------------------
def create_otp(db: Session, phone: str):
    code = str(random.randint(100000, 999999))
    expires_at = datetime.utcnow() + timedelta(minutes=3)

    otp = OtpCode(
        phone=phone,
        code=code,
        expires_at=expires_at
    )

    db.add(otp)
    db.commit()
    db.refresh(otp)

    return otp


# -------------------------------------------------------------------
# 📌 Verify OTP → Auto Login / Auto Signup
# -------------------------------------------------------------------
def verify_otp(db: Session, phone: str, code: str):
    otp = (
        db.query(OtpCode)
        .filter(OtpCode.phone == phone)
        .order_by(OtpCode.id.desc())
        .first()
    )

    if not otp:
        raise HTTPException(status_code=404, detail="OTP not found")

    if otp.code != code:
        raise HTTPException(status_code=400, detail="OTP incorrect")

    if otp.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    # OTP valid → Login or Signup
    user = db.query(User).filter(User.phone == phone).first()

    # Auto-create user if not exists
    if not user:
        user = User(
            phone=phone,
            full_name=None,
            role="user"
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    return user


# -------------------------------------------------------------------
# 📌 Update User Data
# -------------------------------------------------------------------
def update_user(db: Session, user_id: int, data: UserUpdate):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if data.full_name is not None:
        user.full_name = data.full_name

    if data.role is not None:
        user.role = data.role

    db.commit()
    db.refresh(user)
    return user


# -------------------------------------------------------------------
# 📌 Get User by ID
# -------------------------------------------------------------------
def get_user_by_id(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# -------------------------------------------------------------------
# 📌 Get User by Phone
# -------------------------------------------------------------------
def get_user_by_phone(db: Session, phone: str):
    return db.query(User).filter(User.phone == phone).first()


# -------------------------------------------------------------------
# 📌 Get All Users
# -------------------------------------------------------------------
def get_all_users(db: Session):
    return db.query(User).all()

