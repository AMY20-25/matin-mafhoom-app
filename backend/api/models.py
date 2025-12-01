# backend/api/models.py

from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy import (
    String,
    Integer,
    DateTime,
    Boolean,
    UniqueConstraint,
    ForeignKey,
    Text,
    Date
)
from datetime import datetime, date, timezone


# -----------------------------
# Base Model
# -----------------------------
class Base(DeclarativeBase):
    pass


# -----------------------------
# User Table
# -----------------------------
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    first_name: Mapped[str] = mapped_column(String(100), nullable=False, default="")
    last_name: Mapped[str] = mapped_column(String(100), nullable=False, default="")

    phone_number: Mapped[str] = mapped_column(
        String(15), unique=True, index=True, nullable=False
    )

    # تاریخ تولد
    birth_date: Mapped[date | None] = mapped_column(Date, nullable=True)

    # کد معرف برای تخفیف یا دعوت
    referral_code: Mapped[str | None] = mapped_column(String(50), nullable=True)

    # customer / manager / coworker
    role: Mapped[str] = mapped_column(String(20), nullable=False, default="customer")

    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )


# -----------------------------
# OTP Codes
# -----------------------------
class OTPCode(Base):
    __tablename__ = "otp_codes"

    __table_args__ = (
        UniqueConstraint("phone_number", "code", name="uq_phone_code"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    phone_number: Mapped[str] = mapped_column(String(15), index=True, nullable=False)
    code: Mapped[str] = mapped_column(String(6), index=True, nullable=False)

    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )


# -----------------------------
# Coworker Invite Codes
# -----------------------------
class CoworkerInviteCode(Base):
    __tablename__ = "coworker_invite_codes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    # مدیری که کد را ایجاد کرده
    manager_user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"), nullable=False
    )

    # کد خود دعوت‌نامه
    code: Mapped[str] = mapped_column(String(20), unique=True, nullable=False)

    # همکار نهایی که با این کد ثبت‌نام کرده
    coworker_user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"), nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, default=lambda: datetime.now(timezone.utc)
    )

    used_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    # روابط
    manager = relationship("User", foreign_keys=[manager_user_id])
    coworker = relationship("User", foreign_keys=[coworker_user_id])

class Reservation(Base):
    __tablename__ = "reservations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    coworker_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id"), nullable=True
    )

    service_type: Mapped[str] = mapped_column(String(50), nullable=False)
    date: Mapped[datetime.date] = mapped_column(Date, nullable=False)
    time: Mapped[str] = mapped_column(String(10), nullable=False)

    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="pending"
    )

    price: Mapped[int | None] = mapped_column(Integer, nullable=True)
    deposit_paid: Mapped[int | None] = mapped_column(Integer, nullable=True)

    payment_status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="unpaid"
    )

    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    user = relationship("User", foreign_keys=[user_id])
    coworker = relationship("User", foreign_keys=[coworker_id])

class Payment(Base):
    __tablename__ = "payments"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    reservation_id: Mapped[int] = mapped_column(ForeignKey("reservations.id"), nullable=False)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    amount: Mapped[int] = mapped_column(Integer, nullable=False)
    method: Mapped[str] = mapped_column(String(20), nullable=False)  # online / cash
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="pending")

    ref_code: Mapped[str | None] = mapped_column(String(100), nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    reservation = relationship("Reservation")
    user = relationship("User")

class Discount(Base):
    __tablename__ = "discounts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    type: Mapped[str] = mapped_column(String(30), nullable=False)  
    # referral / invitation / manager_manual

    value_percent: Mapped[int | None] = mapped_column(Integer, nullable=True)
    value_amount: Mapped[int | None] = mapped_column(Integer, nullable=True)

    used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    user = relationship("User")

class Referral(Base):
    __tablename__ = "referrals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)

    invited_phone: Mapped[str] = mapped_column(String(15), nullable=False)
    used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    user = relationship("User")

