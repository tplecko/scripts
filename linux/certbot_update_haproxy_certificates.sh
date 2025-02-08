!/usr/bin/env bash

restartHAP=false

check() {
        local cert_file="/etc/ssl/haproxy_certs/$1.pem"
        local expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
        local expiry_seconds=$(date -d "$expiry_date" +%s)
        local current_seconds=$(date +%s)
        local diff_days=$(( (expiry_seconds - current_seconds) / 86400 ))

        if [ "$diff_days" -le 5 ]; then
                echo "Certificate expires in $diff_days days."
                certbot renew --cert-name $1 --force-renewal
                bash -c "cat /etc/letsencrypt/live/$1/fullchain.pem /etc/letsencrypt/live/$1/privkey.pem > /etc/ssl/haproxy_certs/$1.pem"
                restartHAP=true
        else
                echo "Certificate is valid for $diff_days more days."
        fi
}

check "example.com"
check "contoso.com"

if [ "$restartHAP" = true ]; then
        service haproxy reload
fi