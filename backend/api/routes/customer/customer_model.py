from pydantic import BaseModel, Field
from typing import Optional
from sqlalchemy import Column, String, Integer, Boolean, DateTime
from db import Base  # وارد کردن Base از فایل db.py
from datetime import datetime

# --- ۱. مدل داده SQLAlchemy (جدول دیتابیس) ---
class DBCustomer(Base):
    """مدل SQLAlchemy برای جدول مشتریان (CRM)."""
    __tablename__ = "customers_crm"  # استفاده از نام جدید برای تمایز با جدول User
    
    # فیلدهای اصلی جدول
    customer_id = Column(String, primary_key=True, index=True) # شماره موبایل مشتری (کلید اصلی)
    name = Column(String, index=True)
    
    # فیلدهای بازاریابی و وفاداری
    birth_date = Column(String, nullable=True) # برای سهولت فعلاً String
    marriage_date = Column(String, nullable=True) # برای سهولت فعلاً String
    last_visit = Column(DateTime, nullable=True) # تاریخ آخرین مراجعه (Datetime)
    total_visits = Column(Integer, default=0)
    is_vip = Column(Boolean, default=False)
    
    # فیلدهای خدمات
    preferred_service = Column(String, nullable=True)
    notes = Column(String, nullable=True)
    category = Column(String, default="جدید")
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# --- ۲. مدل داده Pydantic (ورودی/خروجی API) ---
class CustomerIn(BaseModel):
    """مدل Pydantic برای ایجاد/به‌روزرسانی مشتری (ورودی API)."""
    customer_id: str = Field(..., description="شماره موبایل مشتری (کلید اصلی)")
    name: str = Field(..., description="نام کامل مشتری")
    
    birth_date: Optional[str] = None
    marriage_date: Optional[str] = None
    last_visit: Optional[str] = None  # ورودی API هنوز می‌تواند String باشد
    preferred_service: Optional[str] = None
    notes: Optional[str] = None
    category: Optional[str] = None
    
    class Config:
        from_attributes = True

class CustomerOut(BaseModel):
    """مدل Pydantic برای خروجی مشتری (خروجی API)."""
    customer_id: str
    name: str
    birth_date: Optional[str] = None
    marriage_date: Optional[str] = None
    last_visit: Optional[datetime] = None # خروجی دیتابیس به صورت DateTime
    total_visits: int = 0
    is_vip: bool = False
    preferred_service: Optional[str] = None
    notes: Optional[str] = None
    category: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
        # در فایل customer_model.py

class CustomerRoot(BaseModel):
    # این به FastAPI می‌گوید که انتظار یک کلید به نام 'body' در ریشه JSON داشته باش.
    body: CustomerIn
