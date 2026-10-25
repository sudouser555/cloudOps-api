
#!/usr/bin/env bash
 
# CloudOps Linux diagnostics
set -u
 
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/logs/diagnostics"
 
mkdir -p "$REPORT_DIR"
 
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
REPORT_FILE="$REPORT_DIR/report_${TIMESTAMP}_$$.log"
 
APP_URL="${APP_URL:-http://127.0.0.1:5000/health}"
 
section() {
    printf '\n========== %s ==========\n' "$1"
}
 
collect_report() {
    section "REPORT INFORMATION"
    printf 'Timestamp (UTC): %s\n' "$(date -u)"
    printf 'Hostname: %s\n' "$(hostname)"
    printf 'User: %s\n' "$(whoami)"
 
    section "SYSTEM UPTIME"
    uptime
 
    section "CPU INFORMATION"
    printf 'Available logical CPUs: '
    nproc
    top -b -n 1 -w 100 | head -n 5
 
    section "MEMORY USAGE"
    free -h
 
    section "DISK USAGE"
    df -h "$PROJECT_DIR"
    du -sh "$PROJECT_DIR"
 
    section "TOP CPU PROCESSES"
    ps -eo pid,user,%cpu,%mem,stat,comm \
        --sort=-%cpu | head -n 11
 
    section "TOP MEMORY PROCESSES"
    ps -eo pid,user,%cpu,%mem,stat,comm \
        --sort=-%mem | head -n 11
 
    section "LISTENING TCP PORTS"
    ss -ltn
 
    section "APPLICATION HEALTH"
    if curl -fsS --connect-timeout 3 \
        --max-time 5 "$APP_URL"; then
        printf '\nApplication HTTP check: SUCCESS\n'
    else
        printf '\nApplication HTTP check: FAILED\n'
    fi
 
    section "END OF REPORT"
}
 
collect_report 2>&1 | tee "$REPORT_FILE"
 
printf '\nReport saved to: %s\n' "$REPORT_FILE"