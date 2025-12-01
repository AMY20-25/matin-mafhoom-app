from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import requests

app = FastAPI()
# مسیر سلامت (health check)
@app.get("/")
def health():
    return {"status": "ok"}
    
def get_country(ip: str) -> str:
    try:
        resp = requests.get(f"http://ip-api.com/json/{ip}", timeout=3)
        data = resp.json()
        return data.get("countryCode", "UNKNOWN")
    except Exception:
        return "UNKNOWN"

@app.middleware("http")
async def vpn_detector(request: Request, call_next):
    user_ip = request.headers.get("CF-Connecting-IP", request.client.host)
    country = get_country(user_ip)

    if country != "IR":
        response = await call_next(request)
        data = {"warning": "بهتره برای سرعت و امنیت بیشتر VPN رو خاموش کنید"}
        return JSONResponse({"result": "ok", **data})

    return await call_next(request)

