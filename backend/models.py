from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    DateTime,
    ForeignKey,
    Float,
    Text
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


# ==============================
# Users Table
# ==============================

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    full_name = Column(String(100), nullable=True)
    role = Column(String(20), default="user")  # user / admin / coworker
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    reservations = relationship("Reservation", back_populates="user")
    payments = relationship("Payment", back_populates="user")
    referral = relationship("Referral", back_populates="user", uselist=False)


# ==============================
# OTP Table
# ==============================

class OtpCode(Base):
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), nullable=False, index=True)
    code = Column(String(6), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


# ==============================
# Invite Codes for Coworkers
# ==============================

class CoworkerInviteCode(Base):
    __tablename__ = "coworker_invite_codes"

    id = Column(Integer, primary_key=True, index=True)
    manager_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    code = Column(String(20), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    manager = relationship("User")


# ==============================
# Reservations
# ==============================

class Reservation(Base):
    __tablename__ = "reservations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    service_type = Column(String(50), nullable=False)  # e.g. haircut, package_x
    date = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(20), default="pending")  # pending / confirmed / done / cancelled
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="reservations")
    payment = relationship("Payment", back_populates="reservation", uselist=False)


# ==============================
# Payment System
# ==============================

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    reservation_id = Column(Integer, ForeignKey("reservations.id"), nullable=True)
    amount = Column(Float, nullable=False)
    payment_type = Column(String(20), nullable=False)  # deposit / full
    status = Column(String(20), default="pending")  # pending / paid / failed
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="payments")
    reservation = relationship("Reservation", back_populates="payment")


# ==============================
# Discounts
# ==============================

class Discount(Base):
    __tablename__ = "discounts"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False)
    discount_percent = Column(Integer, nullable=False)
    max_amount = Column(Float, nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


# ==============================
# Referral System
# ==============================

class Referral(Base):
    __tablename__ = "referrals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    referral_code = Column(String(20), unique=True, nullable=False)
    invited_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="referral")

