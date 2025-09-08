#!/bin/bash

# Configurações
IMAGE_NAME="seuusuario/disparopro-balance-monitor"
TAG="latest"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando deploy da imagem...${NC}"

# Build da imagem
echo "Construindo imagem..."
docker build -t $IMAGE_NAME:$TAG .

# Teste rápido
echo "Testando imagem..."
docker run --rm $IMAGE_NAME:$TAG echo "Build successful!"

# Push para DockerHub
echo "Enviando para DockerHub..."
docker push $IMAGE_NAME:$TAG

echo -e "${GREEN}Deploy concluído com sucesso!${NC}"
echo "Imagem disponível em: https://hub.docker.com/r/seuusuario/disparopro-balance-monitor"