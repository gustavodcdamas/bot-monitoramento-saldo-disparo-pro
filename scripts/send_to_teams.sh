#!/bin/bash

source /app/config/config.env

BALANCE="$1"
CURRENT_DATE=$(date '+%d/%m/%Y')
CURRENT_TIME=$(date '+%H:%M:%S')

# Função para log detalhado
debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - DEBUG: $1" >> /var/log/cron/debug.log
}

# Função para enviar para Teams e retornar status
send_to_teams() {
    local webhook_url="$1"
    local payload="$2"
    
    debug "🌐 Enviando para webhook Teams"
    
    # Enviar para webhook do MS Teams com debug
    response=$(curl -s -k -v -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$webhook_url" 2>> /var/log/cron/teams_debug.log)
    
    local status_code=$(echo "$response" | tail -n1)
    
    debug "📊 Status Code Teams: $status_code"
    
    # Log detalhado do curl teams se disponível
    if [ -f /var/log/cron/teams_debug.log ]; then
        debug "Detalhes da requisição Teams:"
        while read line; do
            debug "   $line"
        done < /var/log/cron/teams_debug.log
        # Limpar debug para próxima execução
        > /var/log/cron/teams_debug.log
    fi
    
    # Retornar 0 para sucesso, 1 para falha
    if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 201 ]; then
        debug "✅ Mensagem enviada com sucesso para MS Teams"
        return 0
    else
        debug "❌ Falha ao enviar para MS Teams. Status: $status_code"
        return 1
    fi
}

debug "💌 Preparando mensagem para MS Teams"
debug "💰 Saldo recebido: '$BALANCE'"

# Determinar se é sucesso ou erro
if echo "$BALANCE" | grep -q "ERRO"; then
    theme_color="FF0000"  # Vermelho para erro
    activity_title="❌ **Erro na Consulta de Saldo**"
    saldo_value="**Indisponível**"
else
    theme_color="0076D7"   # Azul para sucesso
    activity_title="💰 **Saldo Disparo Pro**"
    saldo_value="**R\$ $BALANCE**"
fi

# Criar mensagem JSON para MS Teams
JSON_PAYLOAD=$(cat <<EOF
{
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "themeColor": "$theme_color",
    "summary": "Saldo Disparo Pro - $CURRENT_DATE",
    "sections": [{
        "activityTitle": "$activity_title",
        "activitySubtitle": "Atualizado em: $CURRENT_DATE às $CURRENT_TIME",
        "facts": [{
            "name": "Plataforma:",
            "value": "Disparo Pro"
        }, {
            "name": "Saldo Atual:",
            "value": "$saldo_value"
        }, {
            "name": "Data:",
            "value": "$CURRENT_DATE"
        }],
        "markdown": true
    }]
}
EOF
)

debug "📦 JSON Payload preparado"
debug "🌐 Enviando para: ${MS_TEAMS_WEBHOOK_URL:0:50}..."  # Mostra parte do URL

# Enviar para webhook usando a função
if send_to_teams "$MS_TEAMS_WEBHOOK_URL" "$JSON_PAYLOAD"; then
    debug "✅ Mensagem enviada com sucesso para MS Teams"
    echo "Mensagem enviada para MS Teams: R$ $BALANCE" >> /var/log/cron/disparopro.log
else
    debug "❌ Falha crítica ao enviar para Teams"
fi