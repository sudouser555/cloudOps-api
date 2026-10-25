#!/user/bin/env bash

#Application configuration
APP_NAME="cloudops-api"
HEALTH_URL="http://127.0.0.1:5000/health"

#send HTTP request and capture status
HTTP_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" \
    --connect-timeout 3 \
    --max-time 5 \
    "$HEALTH_URL")

CURL_EXIT_CODE=$?

# check for conection or request failures

if [ "$CURL_EXIT_CODE" -ne 0 ]; then
     echo "[CRITICAL] $APP_NAME is unreachable"
     echo "curl exit code: $CURL_EXIT_CODE"
     exit 2

fi

#check http response

if [ "$HTTP_STATUS" = "200" ]; then
     echo "[OK] $APP_NAME is responding"
     echo "HTTP status: $HTTP_STATUS"
     exit 0
else 
    echo "[CRITICAL] $APP_NAME returned HTTP $HTTP_STATUS"
    exit 2

fi