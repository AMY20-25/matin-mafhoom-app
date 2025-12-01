from sqlalchemy.orm import Session
from datetime import datetime
from fastapi import HTTPException
from models import Discount
from schemas import DiscountCreate


# -------------------------------
# Create discount for a user
# -------------------------------
def create_discount(db: Session, data: DiscountCreate):
    discount = Discount(
        user_id=data.user_id,
        discount_type=data.discount_type,
        percentage=data.percentage,
        valid_until=data.valid_until,
        used=False,  # ensure default
    )

    db.add(discount)
    db.commit()
    db.refresh(discount)
    return discount


# -------------------------------
# Apply discount (mark as used)
# -------------------------------
def apply_discount(db: Session, discount_id: int):
    discount = (
        db.query(Discount)
        .filter(Discount.id == discount_id)
        .first()
    )

    if not discount:
        raise HTTPException(status_code=404, detail="Discount not found")

    # Already used?
    if discount.used:
        raise HTTPException(status_code=400, detail="Discount already used")

    # Expired?
    if discount.valid_until and discount.valid_until < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Discount expired")

    # Mark as used
    discount.used = True
    db.commit()
    db.refresh(discount)

    # Return discount details for UI/backend usage
    return {
        "discount_id": discount.id,
        "percentage": discount.percentage,
        "discount_type": discount.discount_type,
        "valid_until": discount.valid_until,
        "used": discount.used,
    }


# -------------------------------
# Get all discounts for a user
# -------------------------------
def get_user_discounts(db: Session, user_id: int):
    return (
        db.query(Discount)
        .filter(Discount.user_id == user_id)
        .order_by(Discount.created_at.desc())
        .all()
    )

