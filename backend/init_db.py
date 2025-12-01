from database import Base, engine
import models

print("🚀 Creating tables...")

try:
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created successfully")
except Exception as e:
    print("❌ Database init error:", e)

