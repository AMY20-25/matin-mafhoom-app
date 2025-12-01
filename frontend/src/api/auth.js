// فایل: frontend/src/api/auth.js

const API_BASE = "https://api.matinmafhoom.ir";

// درخواست ارسال OTP
export async function requestOtp(phoneNumber) {
  const response = await fetch(`${API_BASE}/auth/request_otp`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ phone_number: phoneNumber }),
  });

  if (!response.ok) {
    throw new Error("خطا در ارسال OTP");
  }
  return await response.json();
}

// تأیید OTP
export async function verifyOtp(phoneNumber, otpCode) {
  const response = await fetch(`${API_BASE}/auth/verify_otp`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      phone_number: phoneNumber,
      otp_code: otpCode,
    }),
  });

  if (!response.ok) {
    throw new Error("خطا در تأیید OTP");
  }
  return await response.json();
}

