from sqlalchemy.orm import Session
from fastapi import HTTPException
from models import Payment, Reservation
from schemas import PaymentCreate

# -------------------------------
# Create or update a payment
# -------------------------------
def create_payment(db: Session, data: PaymentCreate):
    """
    Creates a new payment for a reservation.
    It expects the user_id to be present in the 'data' schema.
    """
    # 1) Find the associated reservation
    reservation = db.query(Reservation).filter(Reservation.id == data.reservation_id).first()
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
        
    # Security check: Ensure the payment is for the correct user of the reservation
    if reservation.user_id != data.user_id:
        raise HTTPException(status_code=403, detail="Payment user does not match reservation user")

    # 2) Check if a payment for this reservation already exists
    existing_payment = db.query(Payment).filter(Payment.reservation_id == data.reservation_id).first()
    
    if existing_payment:
        # This case is complex. For now, let's prevent creating a new payment
        # if one already exists. Logic for updating a failed payment would go here.
        raise HTTPException(status_code=400, detail="A payment for this reservation already exists.")

    # 3) Create new payment record
    new_payment = Payment(
        user_id=data.user_id,
        reservation_id=data.reservation_id,
        amount=data.amount,
        status="paid"  # Assume payment is successful upon creation
    )
    db.add(new_payment)

    # 4) Update reservation payment status
    reservation.payment_status = "paid"
    
    db.commit()
    db.refresh(new_payment)
    db.refresh(reservation) # Also refresh the reservation to get its updated state
    
    return new_payment

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
    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    # The authorization check is handled in the router, so we just return the payment or None
    return payment
