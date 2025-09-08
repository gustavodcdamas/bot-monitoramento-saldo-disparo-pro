#!/bin/bash
# Tentativa mais simples com timeout menor
source /app/config/config.env

response=$(curl -s -k --max-time 15 \
  -H "Authorization: Bearer $DISPAROPRO_API_TOKEN" \
  -X GET \
  "https://apihttp.disparopro.com.br:8433/balance")

if [ $? -eq 0 ]; then
    echo "$response" | jq -r '.detail.saldo'
else
    echo "error"
fi