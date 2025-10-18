#!/data/data/com.termux/files/usr/bin/bash
# Auto-start Agent System on Termux boot
# Requires termux-boot app: https://f-droid.org/en/packages/com.termux.boot/

# Wait for network
sleep 30

# Start agent system
/data/data/com.termux/files/home/start_agent_system.sh

# Log
echo "[$(date)] Agent system auto-started" >> ~/agent-boot.log
