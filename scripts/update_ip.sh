#!/bin/bash

# گرفتن آی‌پی فعلی
CURRENT_IP=$(curl -s ifconfig.me)

# مسیر فایل ذخیره آی‌پی قبلی
IP_FILE="/home/pai2000/.current_ip"

# اگر فایل وجود نداره، آی‌پی رو ذخیره کن
if [ ! -f "$IP_FILE" ]; then
  echo "$CURRENT_IP" > "$IP_FILE"
fi

OLD_IP=$(cat $IP_FILE)

# تابع ساده برای تشخیص آی‌پی ایران (با چک کردن پیش‌شماره‌ها)
is_iran_ip() {
  case $1 in
    2.*|5.*|37.*|79.*|164.*) return 0 ;;  # رنج‌های اصلی ایران
    *) return 1 ;;
  esac
}

# اگر آی‌پی تغییر کرده بود
if [ "$CURRENT_IP" != "$OLD_IP" ]; then
  if is_iran_ip "$CURRENT_IP"; then
    echo "IP تغییر کرد از $OLD_IP به $CURRENT_IP"
    # آپدیت رکورد DNS در Cloudflare
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/<ZONE_ID>/dns_records/<RECORD_ID>" \
         -H "Authorization: Bearer <API_TOKEN>" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"api.matinmafhoom.ir","content":"'$CURRENT_IP'","ttl":120,"proxied":true}'
    echo "$CURRENT_IP" > "$IP_FILE"
  else
    echo "VPN detected ($CURRENT_IP) → DNS آپدیت نشد. لطفاً VPN رو خاموش کنید."
  fi
else
  echo "IP تغییر نکرده. همون قبلیه: $CURRENT_IP"
fi

