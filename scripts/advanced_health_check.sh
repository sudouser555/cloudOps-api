
#!/usr/bin/env bash

# CloudOps advanced health check

set -u

APP_NAME="cloudops-api"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:5000/health}"

MAX_ATTEMPTS=3
RETRY_DELAY=2

LOG_FILE="logs/health_check.log"

mkdir -p "$(dirname "$LOG_FILE")"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp

    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    printf '[%s] [%s] %s\n' \
        "$timestamp" "$level" "$message" |
        tee -a "$LOG_FILE"
}

check_health() {
    local response
    local curl_exit
    local http_status
    local response_body

    response=$(curl -sS \
        --connect-timeout 3 \
        --max-time 5 \
        -w '\n%{http_code}' \
        "$HEALTH_URL" 2>&1)

    curl_exit=$?

    if [ "$curl_exit" -ne 0 ]; then
        log_message "ERROR" \
            "curl failed with exit code $curl_exit"
        return 1
    fi

    http_status="${response##*$'\n'}"
    response_body="${response%$'\n'*}"

    if [ "$http_status" != "200" ]; then
        log_message "ERROR" \
            "Unexpected HTTP status: $http_status"
        return 1
    fi

    if ! printf '%s' "$response_body" |
        python3 -c '
import json
import sys

try:
    data = json.load(sys.stdin)
    healthy = (
        isinstance(data, dict)
        and data.get("status") == "healthy"
    )
    sys.exit(0 if healthy else 1)
except (ValueError, TypeError):
    sys.exit(1)
'; then
        log_message "ERROR" \
            "Invalid JSON or unhealthy application status"
        return 1
    fi

    return 0
}

log_message "INFO" "Starting health check for $APP_NAME"

for ((attempt = 1; attempt <= MAX_ATTEMPTS; attempt++)); do
    log_message "INFO" \
        "Attempt $attempt of $MAX_ATTEMPTS"

    if check_health; then
        log_message "OK" "$APP_NAME is healthy"
        exit 0
    fi

    if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
        log_message "WARN" \
            "Retrying in $RETRY_DELAY seconds"
        sleep "$RETRY_DELAY"
    fi
done

log_message "CRITICAL" \
    "$APP_NAME failed after $MAX_ATTEMPTS attempts"

exit 2
