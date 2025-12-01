from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Import dependencies and models
from database import get_db
from models import User
from crud.crud_payments import (
    create_payment as crud_create_payment,
    get_user_payments,
    get_payment as crud_get_payment,
)
from schemas import PaymentCreate, PaymentResponse
from auth import get_current_user, get_current_admin_user

router = APIRouter(prefix="/payments", tags=["Payments"])

# =====================================================
# Get all payments for the CURRENT logged-in user
# =====================================================
@router.get("/me", response_model=List[PaymentResponse])
def read_my_payments(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Retrieves all payments for the currently authenticated user.
    """
    return get_user_payments(db, user_id=current_user.id)

# =====================================================
# Create a new payment for the CURRENT logged-in user
# =====================================================
@router.post("/", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
def create_new_payment(data: PaymentCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Creates a new payment.
    Ensures that a user can only create a payment for themselves.
    """
    # Security: Ensure the user_id in the payload matches the logged-in user
    if data.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only create payments for yourself.",
        )
    
    # We pass the complete 'data' object to the CRUD function
    return crud_create_payment(db, data)

# =====================================================
# Get single payment by ID (with authorization)
# =====================================================
@router.get("/{payment_id}", response_model=PaymentResponse)
def get_single_payment(payment_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Retrieves a single payment by its ID.
    A user can only see their own payment unless they are an admin.
    """
    payment = crud_get_payment(db, payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
        
    if payment.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized to view this payment")
        
    return payment
