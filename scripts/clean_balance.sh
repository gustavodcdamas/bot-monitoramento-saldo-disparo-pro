#!/bin/bash
# Função para limpar e validar o saldo
clean_balance() {
    local balance="$1"
    
    # Remover quebras de linha, logs e espaços extras
    balance=$(echo "$balance" | tr -d '\n\r' | sed 's/.*R\$ //' | xargs)
    
    # Verificar se é um valor monetário válido
    if echo "$balance" | grep -q -E '^[0-9]+([,.][0-9]{1,2})?$'; then
        echo "$balance"
    else
        echo "error"
    fi
}

# Teste
echo "Saldo limpo: $(clean_balance '$balance')"