from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from auth import get_current_user
from database import get_db
from crud.crud_users import verify_otp
from auth import create_access_token
from schemas import UserOut # We'll create a Token schema later for better practice

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """
    Login endpoint that verifies OTP and returns a JWT access token.
    FastAPI's OAuth2PasswordRequestForm expects a 'username' and 'password'.
    Here, we'll map:
    - username -> phone
    - password -> otp_code
    """
    phone = form_data.username
    otp_code = form_data.password
    
    # Verify the OTP. The verify_otp function returns the user if successful.
    user = verify_otp(db, phone=phone, code=otp_code)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone number or OTP",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    # Create the access token with the user's phone as the subject
    access_token = create_access_token(
        data={"sub": user.phone}
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserOut)
def read_users_me(current_user: UserOut = Depends(get_current_user)):
    """
    A test endpoint to get the current logged-in user's data.
    """
    return current_user
