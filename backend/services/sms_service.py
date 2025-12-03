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
        response.raise_for_status()
        
        response_json = response.json()
        print(f"SMS API Response: {response_json}")

        # --- THE FINAL FIX ---
        # Check for the correct success status from the provider
        if response_json.get("RetStatus") == 1 and len(str(response_json.get("Value"))) > 5:
             print("SUCCESS: SMS considered sent successfully by the provider.")
             return {"status": "success", "message_id": response_json.get("Value")}
        else:
             error_detail = response_json.get("StrRetStatus", "Unknown error")
             print(f"ERROR: SMS provider returned a failure status: {error_detail}")
             raise HTTPException(status_code=500, detail=f"SMS provider error: {error_detail}")

    except requests.RequestException as e:
        print(f"ERROR: Could not connect to SMS service: {e}")
        raise HTTPException(status_code=503, detail="SMS service is currently unavailable.")
