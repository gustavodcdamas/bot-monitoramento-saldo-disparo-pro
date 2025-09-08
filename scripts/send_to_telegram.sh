#!/bin/bash

source /app/config/config.env

BALANCE="$1"
CURRENT_DATE=$(date '+%d/%m/%Y')
CURRENT_TIME=$(date '+%H:%M:%S')

# Função para log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/cron/disparopro.log
}

# Verificar se Telegram está configurado
if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ] || [ "$TELEGRAM_TOKEN" = "sdfdsfsdfsdfsdfsdfsd" ]; then
    log "❌ Telegram não configurado"
    exit 0
fi

# Determinar mensagem
if echo "$BALANCE" | grep -q "ERRO"; then
    message="❌ Erro na Consulta de Saldo Disparo Pro%0A%0A📅 Data: $CURRENT_DATE%0A⏰ Hora: $CURRENT_TIME%0A🔧 Status: Falha na consulta%0A💡 Ação: Verificar logs"
else
    message="💰 Saldo Disparo Pro Atualizado%0A%0A📅 Data: $CURRENT_DATE%0A⏰ Hora: $CURRENT_TIME%0A💵 Saldo: R%24 $BALANCE%0A✅ Status: Consulta bem-sucedida"
fi

# Preparar parâmetros base
params="chat_id=$TELEGRAM_CHAT_ID&text=$message&parse_mode=Markdown"

# Adicionar message_thread_id se estiver configurado e for válido
if [ -n "$TELEGRAM_MESSAGE_THREAD_ID" ] && [ "$TELEGRAM_MESSAGE_THREAD_ID" != "2" ] && [ "$TELEGRAM_MESSAGE_THREAD_ID" != "0" ]; then
    params="$params&message_thread_id=$TELEGRAM_MESSAGE_THREAD_ID"
    log "🔍 Enviando para thread ID: $TELEGRAM_MESSAGE_THREAD_ID"
fi

# Enviar para Telegram usando curl
response=$(curl -s -w "\n%{http_code}" -X POST \
    "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
    -d "$params")

status_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$status_code" -eq 200 ] && echo "$body" | grep -q '"ok":true'; then
    log "✅ Mensagem enviada para Telegram: R$ $BALANCE"
    if [ -n "$TELEGRAM_MESSAGE_THREAD_ID" ] && [ "$TELEGRAM_MESSAGE_THREAD_ID" != "2" ] && [ "$TELEGRAM_MESSAGE_THREAD_ID" != "0" ]; then
        log "   📌 Enviado para o tópico: $TELEGRAM_MESSAGE_THREAD_ID"
    fi
else
    log "❌ Falha ao enviar para Telegram."
    log "📋 Status Code: $status_code"
    log "📋 Response: $body"
    
    # Log adicional para debug
    if echo "$body" | grep -q "bad request"; then
        log "💡 Possível problema: Thread ID inválido ou bot sem permissão no tópico"
    fi
fi