#!/usr/bin/env bash
# soc-eye.sh — Minimal SOC-style live monitoring & alerting
# Author: Sahitya (SOC-Eye series)
# Version: 0.2 (stable)

set -Eeuo pipefail

# ----------------------------- Configuration ---------------------------------
# Default logs to watch (can override via: LOGS="/file1 /file2" ./soc-eye.sh)
LOGS_DEFAULT="/var/log/syslog /var/log/auth.log /var/log/suricata/fast.log"
LOGS=${LOGS:-$LOGS_DEFAULT}

CSV_PATH=${CSV_PATH:-"./soc_eye_events.csv"}
ENABLE_COLOR=1
WRITE_CSV=1

# ----------------------------- Helpers ---------------------------------------
colorize() {
  local color="$1"; shift
  if [[ $ENABLE_COLOR -eq 1 ]]; then
    case "$color" in
      RED) echo -e "\033[31m$*\033[0m" ;;
      YELLOW) echo -e "\033[33m$*\033[0m" ;;
      GREEN) echo -e "\033[32m$*\033[0m" ;;
      CYAN) echo -e "\033[36m$*\033[0m" ;;
      *) echo "$*" ;;
    esac
  else
    echo "$*"
  fi
}

log_event() {
  local severity="$1"; shift
  local msg="$*"
  local ts
  ts=$(date +"%Y-%m-%d %H:%M:%S")
  local line="[$ts] [$severity] $msg"

  case "$severity" in
    HIGH)   colorize RED "$line" ;;
    MEDIUM) colorize YELLOW "$line" ;;
    LOW)    colorize GREEN "$line" ;;
    INFO)   colorize CYAN "$line" ;;
    *) echo "$line" ;;
  esac

  if [[ $WRITE_CSV -eq 1 ]]; then
    echo "\"$ts\",\"$severity\",\"$msg\"" >> "$CSV_PATH"
  fi
}

detect_patterns() {
  local line="$1"
  if [[ "$line" =~ "Failed password" ]]; then
    log_event HIGH "SSH brute-force attempt detected: $line"
  elif [[ "$line" =~ "sudo" && "$line" =~ "authentication failure" ]]; then
    log_event MEDIUM "Sudo misuse attempt: $line"
  elif [[ "$line" =~ "Suricata" ]]; then
    log_event HIGH "IDS alert: $line"
  elif [[ "$line" =~ "wget" || "$line" =~ "curl" ]]; then
    log_event MEDIUM "Suspicious download activity: $line"
  elif [[ "$line" =~ "named" && "$line" =~ "query" ]]; then
    log_event LOW "DNS query observed: $line"
  else
    log_event INFO "$line"
  fi
}

# ----------------------------- Main Loop -------------------------------------
echo "=== SOC-EYE Live Monitoring Started ==="
echo "Watching logs: $LOGS"
echo "Writing events to: $CSV_PATH"
echo "---------------------------------------"

touch "$CSV_PATH"

tail -F $LOGS 2>/dev/null | while read -r line; do
  detect_patterns "$line"
done
