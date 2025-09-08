#!/bin/bash

# Carregar configurações
source /app/config/config.env

# Função para log detalhado (somente arquivo)
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /var/log/cron/disparopro.log
}

# Função para debug (logs mais detalhados)
debug() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - DEBUG: $1" >> /var/log/cron/debug.log
}

# Função para obter saldo da Disparo Pro
get_disparopro_balance() {
    local response
    
    log "🔍 Iniciando consulta à API Disparo Pro"
    debug "URL: https://apihttp.disparopro.com.br:8433/balance"
    debug "Token: ${DISPAROPRO_API_TOKEN:0:10}..."  # Mostra apenas primeiros 10 caracteres
    
    # Fazer requisição para API da Disparo Pro com timeout
    response=$(curl -s -k -v --connect-timeout 60 --max-time 120 -w "\n%{http_code}" \
        -H "Authorization: Bearer $DISPAROPRO_API_TOKEN" \
        -X GET \
        "https://apihttp.disparopro.com.br:8433/balance" 2>> /var/log/cron/curl_debug.log)
    
    local curl_exit_code=$?
    local status_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    debug "Status Code: $status_code"
    debug "Curl Exit Code: $curl_exit_code"
    
    # Log detalhado do curl se disponível
    if [ -f /var/log/cron/curl_debug.log ]; then
        debug "Detalhes da requisição:"
        while read line; do
            debug "   $line"
        done < /var/log/cron/curl_debug.log
        # Limpar debug para próxima execução
        > /var/log/cron/curl_debug.log
    fi
    
    if [ $curl_exit_code -ne 0 ]; then
        log "❌ ERRO CURL: Código $curl_exit_code - Timeout ou falha de conexão"
        debug "Response body: $body"
        echo "error"
        return 1
    fi
    
    if [ "$status_code" -eq 200 ]; then
        # Extrair saldo - estrutura correta baseada na documentação
        local balance=$(echo "$body" | jq -r '.detail.saldo')
        
        if [ "$balance" = "null" ] || [ -z "$balance" ]; then
            log "❌ ERRO: Não foi possível extrair saldo da resposta"
            debug "Response body completo: $body"
            echo "error"
        else
            log "✅ Sucesso! Saldo extraído: R$ $balance"
            debug "Resposta JSON completa: $body"
            echo "$balance"  # ← IMPORTANTE: Retorna APENAS o saldo
        fi
    else
        log "❌ ERRO HTTP: Status: $status_code"
        debug "Response body: $body"
        echo "error"
    fi
}

# Função principal
main() {
    log "Iniciando consulta de saldo Disparo Pro"
    
    local balance=$(get_disparopro_balance)
    
    if [ "$balance" != "error" ]; then
        log "Saldo atual: R$ $balance"
        
        # Enviar para todos os canais
        /app/scripts/send_to_teams.sh "$balance"
        /app/scripts/send_to_discord.sh "$balance"
        /app/scripts/send_to_telegram.sh "$balance"
        /app/scripts/send_to_email.sh "$balance"
        
    else
        log "Falha na consulta do saldo"
        # Enviar alertas de erro
        /app/scripts/send_to_teams.sh "ERRO: Falha ao consultar saldo"
        /app/scripts/send_to_discord.sh "ERRO: Falha ao consultar saldo"
        /app/scripts/send_to_telegram.sh "ERRO: Falha ao consultar saldo"
        /app/scripts/send_to_email.sh "ERRO: Falha ao consultar saldo"
    fi
}

# Executar função principal
main "$@"