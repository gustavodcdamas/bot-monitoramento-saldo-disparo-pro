FROM alpine:3.14

# Metadata
LABEL maintainer="Seu Nome <seu.email@exemplo.com>"
LABEL version="1.0"
LABEL description="Bot para monitoramento de saldo Disparo Pro"

# Instalar dependências
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    tzdata

# Configurar timezone
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Criar usuário não-root para segurança
RUN adduser -D -u 1000 appuser

# Criar diretórios
RUN mkdir -p /app/scripts /app/config /var/log/cron /var/spool/cron/crontabs

# Copiar scripts
COPY scripts/ /app/scripts/
COPY config/ /app/config/

# Dar permissões de execução
RUN chmod +x /app/scripts/*.sh && \
    chown -R appuser:appuser /app

# Criar arquivos de log com permissões corretas
RUN touch /var/log/cron/cron.log /var/log/cron/disparopro.log && \
    chown -R appuser:appuser /var/log/cron && \
    chmod 644 /var/log/cron/*.log

# Mudar para usuário não-root
USER appuser

# Variáveis de ambiente
ENV CONFIG_FILE=/app/config/config.env

# Volume para logs
VOLUME /var/log/cron

# Comando de inicialização
CMD ["crond", "-f", "-d", "8", "-c", "/var/spool/cron/crontabs"]