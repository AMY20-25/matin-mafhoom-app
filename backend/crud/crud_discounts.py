from sqlalchemy.orm import Session
from datetime import datetime
from fastapi import HTTPException
from models import Discount
from schemas import DiscountCreate

# -------------------------------
# Create discount for a user (called by admin)
# -------------------------------
def create_discount(db: Session, data: DiscountCreate):
    """Creates a new discount record in the database."""
    discount = Discount(
        user_id=data.user_id,
        discount_type=data.discount_type,
        percentage=data.percentage,
        valid_until=data.valid_until,
        used=False,
    )
    db.add(discount)
    db.commit()
    db.refresh(discount)
    return discount

# -------------------------------
# Apply discount (mark as used by the owner)
# -------------------------------
def apply_discount(db: Session, discount_id: int, user_id: int):
    """
    Marks a discount as used after verifying ownership and validity.
    """
    discount = db.query(Discount).filter(Discount.id == discount_id).first()

    # --- Authorization and Validation ---
    if not discount:
        raise HTTPException(status_code=404, detail="Discount not found")
    
    if discount.user_id != user_id:
        raise HTTPException(status_code=403, detail="You do not own this discount")

    if discount.used:
        raise HTTPException(status_code=400, detail="Discount already used")

    if discount.valid_until and discount.valid_until < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Discount expired")

    # --- Mark as used ---
    discount.used = True
    db.commit()
    db.refresh(discount)
    
    return discount

# -------------------------------
# Get all discounts for a user
# -------------------------------
def get_user_discounts(db: Session, user_id: int):
    """Retrieves all discounts assigned to a specific user."""
    return (
        db.query(Discount)
        .filter(Discount.user_id == user_id, Discount.used == False) # Also filter for unused discounts
        .order_by(Discount.created_at.desc())
        .all()
    )
