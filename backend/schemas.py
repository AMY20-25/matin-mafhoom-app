from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel, Field
from enum import Enum

class ReservationStatus(str, Enum):
    PENDING = "pending"; CONFIRMED = "confirmed"; CANCELLED = "cancelled"; DONE = "done"

class PaymentStatus(str, Enum):
    UNPAID = "unpaid"; PAID = "paid"; REFUNDED = "refunded"; FAILED = "failed"

class UserBase(BaseModel):
    phone_number: str = Field(..., pattern=r"^09[0-9]{9}$")
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[date] = None

class UserRegister(UserBase): pass

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    birth_date: Optional[date] = None

class UserOut(BaseModel):
    id: int; phone_number: str; first_name: Optional[str]; last_name: Optional[str]; role: str; is_active: bool; created_at: datetime
    class Config: from_attributes = True

class UserCreate(UserBase): role: Optional[str] = "customer"

class ReservationBase(BaseModel):
    user_id: int; service_type: str; date: datetime; notes: Optional[str] = None
class ReservationCreate(ReservationBase): pass
class ReservationUpdate(BaseModel):
    status: Optional[ReservationStatus] = None; payment_status: Optional[PaymentStatus] = None; notes: Optional[str] = None
class ReservationResponse(ReservationBase):
    id: int; coworker_id: Optional[int]; status: ReservationStatus; payment_status: PaymentStatus; created_at: datetime; updated_at: datetime
    class Config: from_attributes = True

class PaymentBase(BaseModel): user_id: int; reservation_id: int; amount: float
class PaymentCreate(PaymentBase): pass
class PaymentResponse(PaymentBase):
    id: int; status: PaymentStatus; created_at: datetime
    class Config: from_attributes = True

class DiscountCreate(BaseModel): user_id: int; discount_type: str; percentage: int; expires_at: Optional[datetime] = None
class DiscountResponse(BaseModel):
    id: int; code: str; percentage: int; used: bool
    class Config: from_attributes = True

# ==============================
# Referrals (Corrected)
# ==============================
class ReferralCreate(BaseModel):
    # The ID of the user who was invited
    invited_user_id: int

class ReferralResponse(BaseModel):
    id: int
    user_id: int # The user who was invited
    invited_by_user_id: int # The user who did the inviting
    used: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

