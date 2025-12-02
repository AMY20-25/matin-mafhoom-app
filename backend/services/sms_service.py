import os
import requests
from fastapi import HTTPException

# --- SMS Service Configuration ---
# Read credentials from environment variables
SMS_USERNAME = os.getenv("SMS_USERNAME")
SMS_PASSWORD = os.getenv("SMS_PASSWORD")
SMS_FROM = os.getenv("SMS_FROM")
SMS_API_URL = "https://rest.payamak-panel.com/api/SendSMS/SendSMS"

def send_sms(phone_number: str, message: str):
    """
    Sends an SMS message using the National SMS Panel API.
    """
    if not all([SMS_USERNAME, SMS_PASSWORD, SMS_FROM]):
        error_msg = "SMS service is not configured. Missing environment variables."
        print(f"ERROR: {error_msg}")
        # In a real app, you might not want to raise an exception here,
        # but for debugging, it's useful.
        raise HTTPException(status_code=500, detail=error_msg)

    payload = {
        "username": SMS_USERNAME,
        "password": SMS_PASSWORD,
        "to": phone_number,
        "from": SMS_FROM,
        "text": message,
        "isflash": False
    }

    try:
        response = requests.post(SMS_API_URL, json=payload, timeout=10)
        response.raise_for_status() # Raise an exception for bad status codes (4xx or 5xx)
        
        response_json = response.json()
        print(f"SMS API Response: {response_json}")

        if response_json.get("Value") == "1000": # Specific success code for this provider
             return {"status": "success", "message": "SMS sent successfully."}
        else:
             # Log the specific error from the provider
             error_detail = response_json.get("StrValue", "Unknown error from SMS provider")
             print(f"ERROR: SMS provider returned an error: {error_detail}")
             raise HTTPException(status_code=500, detail=f"SMS provider error: {error_detail}")

    except requests.RequestException as e:
        print(f"ERROR: Could not connect to SMS service: {e}")
        raise HTTPException(status_code=503, detail="SMS service is currently unavailable.")

