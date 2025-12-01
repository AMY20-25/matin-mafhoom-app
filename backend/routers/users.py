from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from crud.crud_users import create_user, get_user_by_phone, get_user_by_id, get_all_users
from schemas import UserCreate, UserOut

router = APIRouter(prefix="/users", tags=["Users"])


# -------------------------------
# Create new user
# -------------------------------
@router.post("/", response_model=UserOut)
def create_new_user(data: UserCreate, db: Session = Depends(get_db)):
    user = get_user_by_phone(db, data.phone_number)
    if user:
        raise HTTPException(status_code=400, detail="User already registered")
    return create_user(db, data)


# -------------------------------
# Get user by ID
# -------------------------------
@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# -------------------------------
# List all users
# -------------------------------
@router.get("/", response_model=list[UserOut])
def list_users(db: Session = Depends(get_db)):
    return get_all_users(db)

