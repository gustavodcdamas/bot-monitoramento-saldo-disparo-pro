# Disparo Pro Balance Monitor 🐋

Monitoramento automatizado de saldo da plataforma Disparo Pro com notificação no MS Teams, e-mail, telegram e discord

## 📋 Funcionalidades

- ✅ Consulta diária automática do saldo
- ✅ Notificação no Microsoft Teams
- ✅ Notificação no E-mail
- ✅ Notificação no Telegram
- ✅ Notificação no Discord
- ✅ Container Dockerizado
- ✅ Agendamento via Cron
- ✅ Logs detalhados

## 🚀 Como Usar

### Pré-requisitos
- Docker e Docker Compose instalados
- Conta na Disparo Pro
- Webhook do MS Teams configurado

### 1. Clone o repositório
```bash
git clone https://github.com/gustavodcdamas/bot-monitoramento-saldo-disparo-pro.git
cd disparopro-balance-monitor

## 🐋 Como usar via DockerHub

### Pull da imagem:

```bash
docker pull gustavodcdamas/bot-monitoramento-saldo-disparo-pro
```

### Executar container:

```bash
docker run -d \
  --name disparopro-monitor \
  -v $(pwd)/config:/app/config \
  -v $(pwd)/logs:/var/log/cron \
  -e TZ=America/Sao_Paulo \
  --restart unless-stopped \
  gustavodcdamas/bot-monitoramento-saldo-disparo-pro
```

### Usando Docker Compose:

```yaml
version: '3.8'
services:
  disparopro-monitor:
    image: gustavodcdamas/bot-monitoramento-saldo-disparo-pro:latest
    volumes:
      - ./config:/app/config:ro
      - ./logs:/var/log/cron
    environment:
      - TZ=America/Sao_Paulo
    restart: unless-stopped
```

## ⚙️ Configuração

1. Crie o arquivo `config/config.env`:

```env
DISPAROPRO_API_URL="https://api.disparopro.com.br/v1"
DISPAROPRO_API_TOKEN="seu_token_aqui"
MS_TEAMS_WEBHOOK_URL="seu_webhook_teams"
```

## 📊 Logs

Os logs estão disponíveis em `./logs/disparopro.log`

## 🔧 Variáveis de Ambiente

| Variável | Descrição | Obrigatório |
|----------|-----------|-------------|
| `DISPAROPRO_API_TOKEN` | Token da API | Sim |
| `MS_TEAMS_WEBHOOK_URL` | Webhook do Teams | Sim |
| `TZ` | Fuso horário | Não |

## 📝 Licença

MIT License