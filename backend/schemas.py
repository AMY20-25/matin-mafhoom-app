from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel


# ======================================================
# Users
# ======================================================

class UserBase(BaseModel):
    name: Optional[str] = None
    family: Optional[str] = None
    phone: str
    national_code: Optional[str] = None
    avatar_url: Optional[str] = None


class UserCreate(UserBase):
    role: Optional[str] = "customer"


class UserResponse(UserBase):
    id: int
    role: str
    created_at: datetime

    class Config:
        orm_mode = True


class UserUpdate(BaseModel):
    name: Optional[str] = None
    family: Optional[str] = None
    phone: Optional[str] = None
    national_code: Optional[str] = None
    avatar_url: Optional[str] = None
    role: Optional[str] = None

    class Config:
        orm_mode = True


# خروجی عمومی که در روتر users استفاده می‌شود
class UserOut(BaseModel):
    id: int
    name: Optional[str]
    family: Optional[str]
    phone: str
    role: str
    created_at: datetime

    class Config:
        orm_mode = True


# ======================================================
# Reservations
# ======================================================

class ReservationBase(BaseModel):
    user_id: int
    service_type: str
    date: date
    time: str
    price: Optional[int] = None
    deposit_paid: Optional[int] = None
    notes: Optional[str] = None


class ReservationCreate(ReservationBase):
    pass


class ReservationUpdate(BaseModel):
    status: Optional[str] = None
    payment_status: Optional[str] = None
    notes: Optional[str] = None


class ReservationResponse(ReservationBase):
    id: int
    coworker_id: Optional[int] = None
    status: str
    payment_status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True


# ======================================================
# Payments
# ======================================================

class PaymentBase(BaseModel):
    user_id: int
    amount: float


class PaymentCreate(PaymentBase):
    reservation_id: Optional[int] = None


class PaymentResponse(PaymentBase):
    id: int
    reservation_id: Optional[int]
    payment_date: datetime
    status: str
    created_at: datetime

    class Config:
        orm_mode = True


# ======================================================
# Referrals
# ======================================================

class ReferralBase(BaseModel):
    inviter_id: int
    invitee_id: int


class ReferralCreate(ReferralBase):
    pass


class ReferralResponse(ReferralBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True


# ======================================================
# Discounts
# ======================================================

class DiscountBase(BaseModel):
    user_id: int
    discount_type: str
    percentage: int
    valid_until: Optional[datetime] = None


class DiscountCreate(DiscountBase):
    pass


class DiscountResponse(DiscountBase):
    id: int
    used: bool
    created_at: datetime

    class Config:
        orm_mode = True

