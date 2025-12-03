from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# Local Imports
from database import get_db
from models import User, Reservation
from crud import crud_reservations
from schemas import ReservationCreate, ReservationResponse, ReservationUpdate
from auth import get_current_user, get_current_admin_user

router = APIRouter(prefix="/reservations", tags=["Reservations"])

@router.get("/me", response_model=List[ReservationResponse])
def read_my_reservations(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Retrieves all reservations for the currently authenticated user."""
    return crud_reservations.get_user_reservations(db, user_id=current_user.id)

@router.post("/", response_model=ReservationResponse, status_code=status.HTTP_201_CREATED)
def create_new_reservation(data: ReservationCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Creates a new reservation for the currently authenticated user.
    It automatically assigns the user_id from the token, ignoring any user_id in the request body.
    """
    # Override user_id from payload with the one from the token for security
    data.user_id = current_user.id
    
    # We will also need to create the CRUD function for this
    return crud_reservations.create_reservation(db, reservation=data)

@router.get("/{reservation_id}", response_model=ReservationResponse)
def get_single_reservation(reservation_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Retrieves a single reservation by its ID.
    A user can only see their own reservation unless they are an admin.
    """
    reservation = crud_reservations.get_reservation(db, reservation_id)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
        
    if reservation.user_id != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized to view this reservation")
        
    return reservation

# --- ADMIN ONLY ---
@router.get("/", response_model=List[ReservationResponse], dependencies=[Depends(get_current_admin_user)])
def list_all_reservations(db: Session = Depends(get_db)):
    """Retrieves all reservations from all users (Admin only)."""
    return crud_reservations.get_all_reservations(db)

# We might need a PATCH endpoint here later to update reservation status

