#!/bin/bash

# Teste direto sem logs complexos
source /app/config/config.env

echo "Teste simplificado da API Disparo Pro..."
response=$(curl -s -k --max-time 10 \
  -H "Authorization: Bearer $DISPAROPRO_API_TOKEN" \
  -X GET \
  "https://apihttp.disparopro.com.br:8433/balance")

if [ $? -eq 0 ]; then
    balance=$(echo "$response" | jq -r '.detail.saldo')
    if [ "$balance" != "null" ]; then
        echo "✅ Saldo: R$ $balance"
    else
        echo "❌ Erro na resposta: $response"
    fi
else
    echo "❌ Timeout ou erro de conexão"
fi