from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import exc
from db import get_db, engine
from ..customer.customer_model import DBCustomer, CustomerIn, CustomerOut, Base, CustomerRoot # وارد کردن CustomerRoot
from datetime import datetime

# --- ۱. تنظیمات Router ---
router = APIRouter(
    prefix="/customer",
    tags=["CRM - Customers"],
)

# این خط باید در هنگام توسعه فعال باشد تا مطمئن شویم جدول ایجاد شده است.
# Base.metadata.create_all(bind=engine)  

# --- ۲. توابع CRUD دیتابیس ---

def get_customer_by_id(db: Session, customer_id: str):
    """مشتری را بر اساس customer_id از دیتابیس دریافت می‌کند."""
    return db.query(DBCustomer).filter(DBCustomer.customer_id == customer_id).first()

# --- ۳. مسیرهای API ---

@router.post("/", response_model=CustomerOut, status_code=201)
def create_customer(customer_data: CustomerRoot, db: Session = Depends(get_db)):
    """ایجاد یا به‌روزرسانی مشتری CRM."""
    
    # ۱. استخراج داده‌های واقعی مشتری از داخل CustomerRoot
    customer_in = customer_data.body # CustomerIn object
    
    # ۲. بررسی وجود مشتری در دیتابیس
    db_customer = get_customer_by_id(db, customer_id=customer_in.customer_id)
    
    # ۳. تبدیل رشته‌های تاریخ به شیء datetime
    last_visit_dt = None
    if customer_in.last_visit:
        try:
            # سعی می‌کنیم فرمت‌های مختلف تاریخ را بپذیریم (مانند 2025-11-26 10:00:00)
            fmt = "%Y-%m-%d %H:%M:%S" if len(customer_in.last_visit.strip()) > 16 else "%Y-%m-%d %H:%M:%S"
            last_visit_dt = datetime.strptime(customer_in.last_visit.strip(), fmt)
        except ValueError:
            raise HTTPException(status_code=400, detail="فرمت زمان last_visit معتبر نیست. نمونه صحیح: 2025-11-25 10:00:00")
            
    # تبدیل CustomerIn به دیکشنری برای SQLAlchemy (فقط فیلدهای ست شده)
    customer_data_dict = customer_in.model_dump(exclude_unset=True)

    if db_customer:
        # الف) به‌روزرسانی (Update)
        for key, value in customer_data_dict.items():
            # last_visit باید به صورت شیء datetime تنظیم شود
            if key == 'last_visit':
                setattr(db_customer, key, last_visit_dt)
            # از به‌روزرسانی customer_id جلوگیری می‌کنیم و بقیه فیلدها را تنظیم می‌کنیم
            elif key != 'customer_id':
                setattr(db_customer, key, value)
        
        # افزایش total_visits
        db_customer.total_visits = (db_customer.total_visits or 0) + 1
        
        try:
            db.commit()
            db.refresh(db_customer)
        except exc.SQLAlchemyError as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=f"Database error on update: {e}")
        return db_customer
        
    else:
        # ب) ایجاد مشتری جدید (Create)
        new_customer_data = customer_data_dict
        new_customer_data['last_visit'] = last_visit_dt
        new_customer_data['total_visits'] = 1 # اولین مراجعه
        
        new_customer = DBCustomer(**new_customer_data)
        
        try:
            db.add(new_customer)
            db.commit()
            db.refresh(new_customer)
        except exc.SQLAlchemyError as e:
            db.rollback()
            raise HTTPException(status_code=500, detail=f"Database error on create: {e}")

        return new_customer


@router.get("/{customer_id}", response_model=CustomerOut)
def read_customer(customer_id: str, db: Session = Depends(get_db)):
    """دریافت اطلاعات مشتری بر اساس customer_id."""
    db_customer = get_customer_by_id(db, customer_id=customer_id)
    if db_customer is None:
        raise HTTPException(status_code=404, detail="مشتری پیدا نشد.")
    return db_customer

@router.get("/", response_model=List[CustomerOut])
def list_customers(db: Session = Depends(get_db)):
    """دریافت لیست تمامی مشتریان."""
    return db.query(DBCustomer).all()
