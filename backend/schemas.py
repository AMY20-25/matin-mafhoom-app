from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, Field
from enum import Enum

# ==============================
# Enums
# ==============================
class ReservationStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    DONE = "done"

class PaymentStatus(str, Enum):
    UNPAID = "unpaid"
    PAID = "paid"
    REFUNDED = "refunded"
    FAILED = "failed"

# ==============================
# Users
# ==============================
class UserBase(BaseModel):
    phone_number: str = Field(..., pattern=r"^09[0-9]{9}$")
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[date] = None

class UserRegister(UserBase):
    pass

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[date] = None

class UserOut(BaseModel):
    id: int
    phone_number: str
    first_name: Optional[str]
    last_name: Optional[str]
    role: str
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

# Internal use, not exposed to API
class UserCreate(UserBase):
    role: Optional[str] = "customer"

# ==============================
# Reservations
# ==============================
class ReservationBase(BaseModel):
    user_id: int
    service_type: str
    date: datetime
    notes: Optional[str] = None

class ReservationCreate(ReservationBase):
    pass

class ReservationUpdate(BaseModel):
    status: Optional[ReservationStatus] = None
    payment_status: Optional[PaymentStatus] = None
    notes: Optional[str] = None

class ReservationResponse(ReservationBase):
    id: int
    coworker_id: Optional[int]
    status: ReservationStatus
    payment_status: PaymentStatus
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# ==============================
# Payments
# ==============================
class PaymentBase(BaseModel):
    user_id: int
    reservation_id: int
    amount: float

class PaymentCreate(PaymentBase):
    pass

class PaymentResponse(PaymentBase):
    id: int
    status: PaymentStatus
    created_at: datetime
    
    class Config:
        from_attributes = True

# ==============================
# Discounts
# ==============================
class DiscountCreate(BaseModel):
    user_id: int
    discount_type: str
    percentage: int
    expires_at: Optional[datetime] = None

class DiscountResponse(BaseModel):
    id: int
    code: str
    percentage: int
    used: bool
    
    class Config:
        from_attributes = True

# ==============================
# Referrals
# ==============================
class ReferralResponse(BaseModel):
    id: int
    user_id: int
    referral_code: str
    invited_count: int
    
    class Config:
        from_attributes = True
