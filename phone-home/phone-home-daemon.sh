#!/bin/bash
# 🏠 Phone Home Daemon
# Runs in background and periodically syncs with GitHub

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SYNC_INTERVAL="${SYNC_INTERVAL:-3600}"  # 1 hour
LOG_FILE="$HOME/.phone-home.log"

echo "[$(date)] Phone Home daemon started" >> "$LOG_FILE"

while true; do
    # Run sync
    if bash "$DOTFILES_DIR/phone-home/sync.sh" >> "$LOG_FILE" 2>&1; then
        echo "[$(date)] ✅ Sync successful" >> "$LOG_FILE"
    else
        echo "[$(date)] ❌ Sync failed" >> "$LOG_FILE"
    fi

    # Wait before next sync
    sleep "$SYNC_INTERVAL"
done
