from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from crud.crud_payments import (
    create_payment as crud_create_payment,
    get_user_payments,
    get_payment,
)
from schemas import PaymentCreate, PaymentResponse

router = APIRouter(prefix="/payments", tags=["Payments"])


# =====================================================
# Create a new payment
# =====================================================
@router.post("/", response_model=PaymentResponse)
def create_new_payment(
    data: PaymentCreate,
    user_id: int,
    db: Session = Depends(get_db)
):
    try:
        return crud_create_payment(db, data, user_id)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error: " + str(e))


# =====================================================
# Get all payments for a specific user
# =====================================================
@router.get("/user/{user_id}", response_model=list[PaymentResponse])
def list_user_payments(user_id: int, db: Session = Depends(get_db)):
    return get_user_payments(db, user_id)


# =====================================================
# Get payment by ID
# =====================================================
@router.get("/{payment_id}", response_model=PaymentResponse)
def get_payment_route(payment_id: int, db: Session = Depends(get_db)):
    payment = get_payment(db, payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment

