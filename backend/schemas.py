from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel
from enum import Enum

class ReservationStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"

class PaymentStatus(str, Enum):
    UNPAID = "unpaid"
    PAID = "paid"
    REFUNDED = "refunded"

# ======================================================
# Users
# ======================================================

class UserBase(BaseModel):
    name: Optional[str] = None
    family: Optional[str] = None
    phone: str
    national_code: Optional[str] = None
    avatar_url: Optional[str] = None

class UserRegister(BaseModel):
    phone: str
    name: Optional[str] = None
    family: Optional[str] = None

class UserCreate(UserBase):
    role: Optional[str] = "customer"

class UserResponse(UserBase):
    id: int
    role: str
    created_at: datetime
    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    family: Optional[str] = None
    phone: Optional[str] = None
    national_code: Optional[str] = None
    avatar_url: Optional[str] = None
    role: Optional[str] = None
    class Config:
        from_attributes = True

class UserOut(BaseModel):
    id: int
    name: Optional[str]
    family: Optional[str]
    phone: str
    role: str
    created_at: datetime
    class Config:
        from_attributes = True

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
    status: Optional[ReservationStatus] = None
    payment_status: Optional[PaymentStatus] = None
    notes: Optional[str] = None

class ReservationResponse(ReservationBase):
    id: int
    coworker_id: Optional[int] = None
    status: ReservationStatus
    payment_status: PaymentStatus
    created_at: datetime
    updated_at: datetime
    class Config:
        from_attributes = True

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
    status: PaymentStatus
    created_at: datetime
    class Config:
        from_attributes = True

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
        from_attributes = True

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
        from_attributes = True
