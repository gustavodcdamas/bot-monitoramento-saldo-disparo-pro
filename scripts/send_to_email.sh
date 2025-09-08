#!/bin/bash

source /app/config/config.env

BALANCE="$1"
CURRENT_DATE=$(date '+%d/%m/%Y')
CURRENT_TIME=$(date '+%H:%M:%S')

# Função para log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/cron/disparopro.log
}

# Verificar se email está configurado
if [ -z "$SMTP_TO" ] || [ "$SMTP_TO" = "email@email.com" ] || [ -z "$SMTP_SERVER" ]; then
    log "❌ Email não configurado"
    exit 0
fi

# Determinar assunto e corpo
if echo "$BALANCE" | grep -q "ERRO"; then
    subject="Erro na Consulta de Saldo Disparo Pro - $CURRENT_DATE"
    body="Falha na consulta do saldo Disparo Pro<br><br>Data: $CURRENT_DATE<br>Hora: $CURRENT_TIME<br>Status: Erro na consulta<br><br>Verifique os logs para mais detalhes."
else
    subject="Saldo Disparo Pro - R$ $BALANCE - $CURRENT_DATE"
    body="Saldo Disparo Pro atualizado com sucesso!<br>Data: $CURRENT_DATE<br>Hora: $CURRENT_TIME<br>Saldo: R$ $BALANCE<br>Status: Consulta bem-sucedida<br><br>Este é um email automático do sistema de monitoramento."
fi

# Enviar email usando curl com SMTP
email_data=$(cat <<EOF
FROM: $SMTP_FROM
TO: $SMTP_TO
SUBJECT: $subject
CONTENT-TYPE: text/plain; charset=UTF-8

$body
EOF
)

# Enviar email via curl
response=$(curl -s \
    --mail-from "$SMTP_FROM" \
    --mail-rcpt "$SMTP_TO" \
    --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --user "$SMTP_USER:$SMTP_PASS" \
    --ssl-reqd \
    --upload-file - <<< "$email_data" 2>&1)

result=$?

if [ $result -eq 0 ]; then
    log "✅ Email enviado para $SMTP_TO: R$ $BALANCE"
else
    log "❌ Falha ao enviar email. Código: $result"
    log "📋 Erro: $response"
fi