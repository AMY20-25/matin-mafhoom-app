from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime

from models import Reservation
from schemas import ReservationCreate, ReservationUpdate

def get_reservation(db: Session, reservation_id: int):
    """Retrieves a single reservation by its ID."""
    return db.query(Reservation).filter(Reservation.id == reservation_id).first()

def get_user_reservations(db: Session, user_id: int):
    """Retrieves all reservations for a specific user."""
    return db.query(Reservation).filter(Reservation.user_id == user_id).order_by(Reservation.date.desc()).all()

def get_all_reservations(db: Session):
    """Retrieves all reservations from the database (for admin)."""
    return db.query(Reservation).order_by(Reservation.date.desc()).all()

def check_reservation_conflict(db: Session, date: datetime):
    """
    Checks if a reservation already exists for a given datetime slot.
    This is a simplified check. A real-world scenario would be more complex.
    """
    return db.query(Reservation).filter(Reservation.date == date, Reservation.status != "cancelled").first()

def create_reservation(db: Session, reservation: ReservationCreate):
    """Creates a new reservation record."""
    
    # 1. Check for time conflicts
    conflict = check_reservation_conflict(db, date=reservation.date)
    if conflict:
        raise HTTPException(
            status_code=409, # 409 Conflict is more appropriate
            detail="This time slot is already reserved.",
        )
        
    # 2. Create the new Reservation model instance
    db_reservation = Reservation(
        user_id=reservation.user_id,
        service_type=reservation.service_type,
        date=reservation.date,
        notes=reservation.notes,
        status="pending", # Default status
        payment_status="unpaid" # Default status
    )
    
    db.add(db_reservation)
    db.commit()
    db.refresh(db_reservation)
    return db_reservation

def update_reservation(db: Session, reservation_id: int, data: ReservationUpdate):
    """Updates a reservation's status or notes."""
    db_reservation = get_reservation(db, reservation_id)
    if not db_reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    
    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_reservation, key, value)
        
    db.commit()
    db.refresh(db_reservation)
    return db_reservation

