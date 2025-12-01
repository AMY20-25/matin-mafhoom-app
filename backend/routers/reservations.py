from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import Reservation
from crud.crud_reservations import (
    create_reservation as crud_create_reservation,
    get_reservation,
    get_user_reservations,
)
from schemas import ReservationCreate, ReservationResponse

router = APIRouter(prefix="/reservations", tags=["Reservations"])


# =====================================================
# Get reservations for a specific user
# =====================================================
@router.get("/user/{user_id}", response_model=list[ReservationResponse])
def reservations_for_user(user_id: int, db: Session = Depends(get_db)):
    return get_user_reservations(db, user_id)


# =====================================================
# Get single reservation by ID
# =====================================================
@router.get("/{reservation_id}", response_model=ReservationResponse)
def get_reservation_route(reservation_id: int, db: Session = Depends(get_db)):
    return get_reservation(db, reservation_id)


# =====================================================
# List all reservations (ADMIN ONLY)
# =====================================================
@router.get("/", response_model=list[ReservationResponse])
def list_all_reservations(db: Session = Depends(get_db)):
    return db.query(Reservation).order_by(Reservation.date.desc()).all()


# =====================================================
# Create a new reservation
# =====================================================
@router.post("/", response_model=ReservationResponse)
def create_new_reservation(data: ReservationCreate, db: Session = Depends(get_db)):
    try:
        return crud_create_reservation(db, data)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error: " + str(e))

