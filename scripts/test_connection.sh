#!/bin/bash

source /app/config/config.env

echo "Testando conexão com API Disparo Pro..."
response=$(curl -s -k -H "Authorization: Bearer $DISPAROPRO_API_TOKEN" \
    -X GET "https://apihttp.disparopro.com.br:8433/balance")

echo "Resposta da API:"
echo "$response" | jq .

# Testar extração do saldo
balance=$(echo "$response" | jq -r '.detail.saldo')
echo "Saldo extraído: $balance"