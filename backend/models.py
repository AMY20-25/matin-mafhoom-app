from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, ForeignKey, Float, Text, Date
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String(15), unique=True, index=True, nullable=False)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    role = Column(String(20), default="customer", nullable=False)
    birth_date = Column(Date, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    
    reservations = relationship("Reservation", foreign_keys="[Reservation.user_id]", back_populates="user")
    managed_coworkers = relationship("CoworkerInviteCode", foreign_keys="[CoworkerInviteCode.manager_id]", back_populates="manager")
    payments = relationship("Payment", back_populates="user")
    
    # This relationship seems incorrect based on the new understanding of 'referrals' table.
    # We will adjust or remove it. For now, let's keep it commented.
    # referral = relationship("Referral", back_populates="user", uselist=False)

class OtpCode(Base):
    __tablename__ = "otp_codes"
    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String(15), nullable=False, index=True)
    code = Column(String(6), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)

class CoworkerInviteCode(Base):
    __tablename__ = "coworker_invite_codes"
    id = Column(Integer, primary_key=True, index=True)
    manager_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    code = Column(String(20), unique=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    manager = relationship("User", foreign_keys=[manager_id], back_populates="managed_coworkers")

class Reservation(Base):
    __tablename__ = "reservations"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    coworker_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    service_type = Column(String(50), nullable=False)
    date = Column(DateTime, nullable=False)
    status = Column(String(20), default="pending", nullable=False)
    payment_status = Column(String(20), default="unpaid", nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    user = relationship("User", foreign_keys=[user_id], back_populates="reservations")
    payment = relationship("Payment", back_populates="reservation", uselist=False)

class Payment(Base):
    __tablename__ = "payments"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    reservation_id = Column(Integer, ForeignKey("reservations.id"), nullable=True)
    amount = Column(Float, nullable=False)
    payment_type = Column(String(20), nullable=True)
    status = Column(String(20), default="pending", nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    user = relationship("User", back_populates="payments")
    reservation = relationship("Reservation", back_populates="payment")

class Discount(Base):
    __tablename__ = "discounts"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    code = Column(String(50), unique=True, nullable=False)
    discount_type = Column(String(50), nullable=False)
    percentage = Column(Integer, nullable=False)
    max_amount = Column(Float, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    used = Column(Boolean, default=False, nullable=False)

# ==============================
# Referral System (Final Correction)
# ==============================
class Referral(Base):
    __tablename__ = "referrals"
    id = Column(Integer, primary_key=True, index=True)
    # The user who WAS invited
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    # The phone number of the user who DID the inviting
    invited_phone = Column(String(15), nullable=False)
    used = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    
    # Relationship to the invited user
    invited_user = relationship("User", foreign_keys=[user_id])

