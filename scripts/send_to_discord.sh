#!/bin/bash

source /app/config/config.env

BALANCE="$1"
CURRENT_DATE=$(date '+%d/%m/%Y')
CURRENT_TIME=$(date '+%H:%M:%S')

# Função para log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/cron/disparopro.log
}

# Verificar se webhook está configurado
if [ -z "$DISCORD_WEBHOOK_URL" ] || [ "$DISCORD_WEBHOOK_URL" = "https://discord.com/api/webhooks/your-webhook" ]; then
    log "❌ Discord webhook não configurado"
    exit 0
fi

# Determinar cor e conteúdo
if echo "$BALANCE" | grep -q "ERRO"; then
    color="15158332"  # Vermelho para erro
    title="❌ Erro na Consulta de Saldo"
    description="Falha ao consultar saldo da Disparo Pro"
else
    color="3447003"   # Azul para sucesso
    title="💰 Saldo Disparo Pro"
    description="Saldo atualizado em: $CURRENT_DATE às $CURRENT_TIME"
fi

# Criar mensagem JSON para Discord
JSON_PAYLOAD=$(cat <<EOF
{
    "embeds": [
        {
            "title": "$title",
            "description": "$description",
            "color": $color,
            "fields": [
                {
                    "name": "Plataforma",
                    "value": "Disparo Pro",
                    "inline": true
                },
                {
                    "name": "Saldo Atual",
                    "value": "R\$ $BALANCE",
                    "inline": true
                },
                {
                    "name": "Data",
                    "value": "$CURRENT_DATE",
                    "inline": true
                }
            ],
            "footer": {
                "text": "Atualizado em: $CURRENT_TIME"
            }
        }
    ]
}
EOF
)

# Enviar para webhook do Discord
response=$(curl -s -w "\n%{http_code}" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD" \
    "$DISCORD_WEBHOOK_URL" 2>&1)

status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 204 ]; then
    log "✅ Mensagem enviada para Discord: R$ $BALANCE"
else
    log "❌ Falha ao enviar para Discord. Status: $status_code"
    log "📋 Response: $response"
fi