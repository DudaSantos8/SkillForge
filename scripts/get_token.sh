#!/bin/bash

TOKEN_FILE="./scripts/token.txt"
API_URL='https://idm.stackspot.com/zup/oidc/oauth/token'
CLIENT_ID='387c39a2-3876-43fa-9b1b-848a44213100'
CLIENT_SECRET='9MbJ68x4R22Xp1p7mwOPMpi1bDiYM42S78Dp7BgJQCJljkxU04x7h7YMo9ewmoO3'

# Verifica se o jq está instalado
if ! command -v jq &> /dev/null; then
    echo "❌ Erro: 'jq' não está instalado. Instale-o com 'sudo apt install jq' ou 'sudo yum install jq'."
    exit 1
fi

# Função para obter um novo token
gerar_novo_token() {
    echo "🔄 Obtendo novo token..."
    RESPONSE=$(curl --silent --location --request POST "$API_URL" \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode "client_id=$CLIENT_ID" \
        --data-urlencode 'grant_type=client_credentials' \
        --data-urlencode "client_secret=$CLIENT_SECRET")

    # Verifica se a resposta é um JSON válido
    if echo "$RESPONSE" | jq . > /dev/null 2>&1; then
        NEW_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

        if [ -n "$NEW_TOKEN" ] && [ "$NEW_TOKEN" != "null" ]; then
            echo "$NEW_TOKEN" > "$TOKEN_FILE"
            echo "✅ Novo token salvo em $TOKEN_FILE."
        else
            echo "❌ Erro ao obter o novo token! A resposta da API não contém um token válido."
            exit 1
        fi
    else
        echo "❌ Erro ao obter o token! A resposta da API não é um JSON válido."
        exit 1
    fi
}

# Sempre gera um novo token e substitui o antigo
gerar_novo_token

# Exibe o token atualizado
cat "$TOKEN_FILE"
