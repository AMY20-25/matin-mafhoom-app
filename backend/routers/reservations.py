from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Import dependencies and models
from database import get_db
from models import User, Reservation
from crud.crud_reservations import (
    create_reservation as crud_create_reservation,
    get_reservation as crud_get_reservation,
    get_user_reservations,
    get_all_reservations, # We will create this function
)
from schemas import ReservationCreate, ReservationResponse
from auth import get_current_user, get_current_admin_user

router = APIRouter(prefix="/reservations", tags=["Reservations"])

# =====================================================
# Get reservations for the CURRENT logged-in user
# Path changed from /user/{user_id} to /me for security
# =====================================================
@router.get("/me", response_model=List[ReservationResponse])
def read_my_reservations(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Retrieves all reservations for the currently authenticated user.
    """
    return get_user_reservations(db, user_id=current_user.id)

# =====================================================
# List all reservations (ADMIN ONLY)
# =====================================================
@router.get("/", response_model=List[ReservationResponse])
def list_all_reservations(db: Session = Depends(get_db), admin_user: User = Depends(get_current_admin_user)):
    """
    Retrieves all reservations from all users.
    Requires admin privileges.
    """
    # This logic should be in a CRUD function for consistency
    return db.query(Reservation).order_by(Reservation.date.desc()).all()

# =====================================================
# Create a new reservation for the CURRENT logged-in user
# =====================================================
@router.post("/", response_model=ReservationResponse, status_code=status.HTTP_201_CREATED)
def create_new_reservation(data: ReservationCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Creates a new reservation.
    The user_id from the request body is IGNORED, and the id from the
    logged-in user's token is used instead, for security.
    """
    # Security: Ensure the user_id in the payload matches the logged-in user
    if data.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only create reservations for yourself.",
        )
    
    try:
        return crud_create_reservation(db, data)
    except Exception as e:
        # A more specific exception handling would be better
        raise HTTPException(status_code=500, detail="An internal error occurred.")

# =====================================================
# Get single reservation by ID
# This still needs authorization logic to check if the user is an admin
# or the owner of the reservation.
# =====================================================
@router.get("/{reservation_id}", response_model=ReservationResponse)
def get_single_reservation(reservation_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Retrieves a single reservation by its ID.
    A user can only see their own reservation unless they are an admin.
    """
    reservation = crud_get_reservation(db, reservation_id)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
        
    if reservation.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized to view this reservation")
        
    return reservation
