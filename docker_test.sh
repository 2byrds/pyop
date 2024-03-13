#!/bin/bash

# docker build -t pyop .

# docker run -p 9090:9090 pyop

# Variables
REGISTRATION_ENDPOINT="https://localhost:9090/registration"
AUTHORIZATION_ENDPOINT="https://localhost:9090/authentication"
TOKEN_ENDPOINT="https://localhost:9090/token"
REDIRECT_URI="http://localhost"
STATE="1234"

# Client metadata
CLIENT_METADATA='{
  "redirect_uris": ["'"${REDIRECT_URI}"'"],
  "client_name": "Test Client",
  "token_endpoint_auth_method": "client_secret_basic",
  "grant_types": ["authorization_code", "refresh_token"],
  "response_types": ["code"],
  "scope": "openid profile"
}'
echo "Client Metadata: ${CLIENT_METADATA}"

# Register the client
CLIENT_INFO=$(curl -k -s -X POST -H "Content-Type: application/json" -d "${CLIENT_METADATA}" ${REGISTRATION_ENDPOINT})
echo "Client Info: ${CLIENT_INFO}"

# Extract the client ID and secret from the response
CLIENT_ID=$(echo ${CLIENT_INFO} | jq -r .client_id)
echo "Client ID: ${CLIENT_ID}"
CLIENT_SECRET=$(echo ${CLIENT_INFO} | jq -r .client_secret)

# Step 1: Authorization Request
# Display the authorization URL to the user
echo "Please navigate to the following URL in your web browser:"
echo "${AUTHORIZATION_ENDPOINT}?response_type=code&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=openid&state=${STATE}"

# Wait for user to enter the authorization code
echo "After you authenticate, you'll be redirected to a URL that includes an 'code' parameter in the query string. Please enter the 'code' value here:"
read AUTHORIZATION_CODE

# Encode the client ID and secret in Base64
CLIENT_AUTH=$(echo -n "${CLIENT_ID}:${CLIENT_SECRET}" | base64)
echo "Client auth headers: ${CLIENT_AUTH}"

# Remove the client_id and client_secret from the request body
tparams="grant_type=authorization_code&code=${AUTHORIZATION_CODE}&redirect_uri=${REDIRECT_URI}"
echo "Token Request Parameters: ${tparams}"
# Add the Authorization header to the curl command
TOKEN_RESPONSE=$(curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: Basic ${CLIENT_AUTH}" -d "${tparams}" ${TOKEN_ENDPOINT})

# Extract the tokens from the response
ACCESS_TOKEN=$(echo ${TOKEN_RESPONSE} | jq -r .access_token)
ID_TOKEN=$(echo ${TOKEN_RESPONSE} | jq -r .id_token)
REFRESH_TOKEN=$(echo ${TOKEN_RESPONSE} | jq -r .refresh_token)

# Print the tokens
echo "Access Token: ${ACCESS_TOKEN}"
echo "ID Token: ${ID_TOKEN}"
echo "Refresh Token: ${REFRESH_TOKEN}"