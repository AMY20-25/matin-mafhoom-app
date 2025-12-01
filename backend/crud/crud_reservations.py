from sqlalchemy.orm import Session
from fastapi import HTTPException
from datetime import datetime, timedelta
from models import Reservation
from schemas import ReservationCreate, ReservationUpdate


# -------------------------------
# Check time conflict
# -------------------------------
def check_reservation_conflict(db: Session, date, start_time, end_time):
    conflict = (
        db.query(Reservation)
        .filter(
            Reservation.date == date,
            Reservation.start_time < end_time,
            Reservation.end_time > start_time,
            Reservation.status != "canceled",
        )
        .first()
    )
    return conflict


# -------------------------------
# Create a reservation
# -------------------------------
def create_reservation(db: Session, data: ReservationCreate, user_id: int):
    # 1) Check conflict
    conflict = check_reservation_conflict(
        db, data.date, data.start_time, data.end_time
    )
    if conflict:
        raise HTTPException(
            status_code=400,
            detail="Time slot already reserved",
        )

    # 2) Create reservation
    reservation = Reservation(
        user_id=user_id,
        service_id=data.service_id,
        date=data.date,
        start_time=data.start_time,
        end_time=data.end_time,
        note=data.note,
        status="pending",
        price=data.price,
        deposit_amount=data.deposit_amount,
        is_paid=False,
    )

    db.add(reservation)
    db.commit()
    db.refresh(reservation)
    return reservation


# -------------------------------
# Update reservation status OR time OR notes
# -------------------------------
def update_reservation(db: Session, reservation_id: int, data: ReservationUpdate):
    reservation = (
        db.query(Reservation)
        .filter(Reservation.id == reservation_id)
        .first()
    )

    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")

    # Update only provided fields
    if data.date:
        reservation.date = data.date
    if data.start_time:
        reservation.start_time = data.start_time
    if data.end_time:
        reservation.end_time = data.end_time
    if data.note is not None:
        reservation.note = data.note
    if data.status:
        reservation.status = data.status

    db.commit()
    db.refresh(reservation)
    return reservation


# -------------------------------
# Get reservations for a user
# -------------------------------
def get_user_reservations(db: Session, user_id: int):
    return (
        db.query(Reservation)
        .filter(Reservation.user_id == user_id)
        .order_by(Reservation.date, Reservation.start_time)
        .all()
    )


# -------------------------------
# Get single reservation
# -------------------------------
def get_reservation(db: Session, reservation_id: int):
    reservation = (
        db.query(Reservation)
        .filter(Reservation.id == reservation_id)
        .first()
    )
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    return reservation

