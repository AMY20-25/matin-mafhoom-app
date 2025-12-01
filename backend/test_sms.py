from melipayamak import Api

# اطلاعات پنل ملی‌پیامک
USERNAME = "9365894514"
PASSWORD = "0dd8b018-e01a-4cd9-af61-8f7c0c96271e"

api = Api(USERNAME, PASSWORD)
sms = api.sms()

# شماره مقصد، سرشماره و متن پیامک
to = "09365894514"
_from = "50004001894514"   # سرشماره‌ای که در پنل داری
text = "کد تست OTP از بک‌اند"

# ارسال
response = sms.send(to, _from, text)
print(response)

