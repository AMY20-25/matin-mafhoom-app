from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import User
from crud.crud_discounts import (
    create_discount as crud_create_discount,
    get_user_discounts,
    apply_discount as crud_apply_discount,
)
from schemas import DiscountCreate, DiscountResponse
from auth import get_current_user, get_current_admin_user

router = APIRouter(prefix="/discounts", tags=["Discounts"])

@router.post("/", response_model=DiscountResponse, status_code=status.HTTP_201_CREATED)
def create_new_discount(data: DiscountCreate, db: Session = Depends(get_db), admin_user: User = Depends(get_current_admin_user)):
    return crud_create_discount(db, data)

@router.get("/me", response_model=List[DiscountResponse])
def read_my_discounts(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return get_user_discounts(db, user_id=current_user.id)

@router.post("/apply/{discount_id}", response_model=DiscountResponse)
def apply_user_discount(discount_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        return crud_apply_discount(db, discount_id=discount_id, user_id=current_user.id)
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="An internal error occurred while applying discount.")
