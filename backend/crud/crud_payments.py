from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime
from models import Payment, Reservation
from schemas import PaymentCreate


# -------------------------------
# Create or update a payment
# -------------------------------
def create_payment(db: Session, data: PaymentCreate, user_id: int):

    # 1) Find reservation
    reservation = (
        db.query(Reservation)
        .filter(Reservation.id == data.reservation_id)
        .first()
    )

    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")

    # 2) Check if payment already exists
    payment = (
        db.query(Payment)
        .filter(Payment.reservation_id == data.reservation_id)
        .first()
    )

    # ---------------------------------------
    # Case A: First payment (deposit OR full)
    # ---------------------------------------
    if not payment:
        payment = Payment(
            user_id=user_id,
            reservation_id=data.reservation_id,
            amount=data.amount,
            payment_type=data.payment_type,  # "deposit" or "full"
            status="paid",
        )

        db.add(payment)

        # Update reservation status
        if data.payment_type == "full":
            reservation.status = "done"
        else:
            reservation.status = "deposit_paid"

        db.commit()
        db.refresh(payment)
        return payment

    # ---------------------------------------
    # Case B: Update existing payment
    # ---------------------------------------
    if payment.status == "paid":
        raise HTTPException(
            status_code=400,
            detail="Payment already completed"
        )

    # Update payment record
    payment.amount = data.amount
    payment.payment_type = data.payment_type
    payment.status = "paid"

    # Update reservation
    if data.payment_type == "full":
        reservation.status = "done"
    else:
        reservation.status = "deposit_paid"

    db.commit()
    db.refresh(payment)
    return payment


# -------------------------------
# Get all payments for a user
# -------------------------------
def get_user_payments(db: Session, user_id: int):
    return (
        db.query(Payment)
        .filter(Payment.user_id == user_id)
        .order_by(Payment.created_at.desc())
        .all()
    )


# -------------------------------
# Get single payment
# -------------------------------
def get_payment(db: Session, payment_id: int):
    payment = (
        db.query(Payment)
        .filter(Payment.id == payment_id)
        .first()
    )

    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    return payment

