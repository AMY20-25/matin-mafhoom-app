from db import SessionLocal
from models import User
from datetime import date

def main():
    db = SessionLocal()
    # درج یک کاربر تستی
    new_user = User(
        first_name="Ali",
        last_name="Ahmadi",
        phone_number="09120000000",
        birth_date=date(1990, 1, 1),
        role="customer"
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    print("Inserted user:", new_user.id, new_user.first_name, new_user.phone_number)

    # خواندن همه کاربران
    users = db.query(User).all()
    for u in users:
        print("User:", u.id, u.first_name, u.last_name, u.phone_number)

    db.close()

if __name__ == "__main__":
    main()
