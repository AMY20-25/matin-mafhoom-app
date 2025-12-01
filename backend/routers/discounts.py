from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from crud.crud_discounts import (
    create_discount as crud_create_discount,
    apply_discount,
    get_user_discounts,
)
from schemas import DiscountCreate, DiscountResponse

router = APIRouter(prefix="/discounts", tags=["Discounts"])


# =====================================================
# Create a discount (admin or system)
# =====================================================
@router.post("/", response_model=DiscountResponse)
def create_new_discount(
    data: DiscountCreate,
    db: Session = Depends(get_db)
):
    try:
        return crud_create_discount(db, data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# Apply/Use a discount
# =====================================================
@router.post("/apply/{discount_id}", response_model=DiscountResponse)
def apply_user_discount(discount_id: int, db: Session = Depends(get_db)):
    try:
        return apply_discount(db, discount_id)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# =====================================================
# Get discount list for a user
# =====================================================
@router.get("/user/{user_id}", response_model=list[DiscountResponse])
def list_discounts_for_user(user_id: int, db: Session = Depends(get_db)):
    return get_user_discounts(db, user_id)

