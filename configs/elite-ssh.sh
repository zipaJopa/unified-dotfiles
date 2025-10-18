# ===== ELITE SSH SHORTCUTS =====
# Single-letter commands for infrastructure access

# === PROXMOX ===
alias px='ssh root@100.118.205.79'                    # p[x]
alias pxl='ssh root@192.168.0.50'                      # px [l]ocal

# === PROXMOX CONTAINERS ===
alias arc='ssh root@100.118.205.79 pct enter 103'     # archon
alias api='ssh root@100.118.205.79 pct enter 112'     # one-api
alias sky='ssh root@100.118.205.79 pct enter 107'     # skyvern
alias fc='ssh root@100.118.205.79 pct enter 116'      # firecrawl
alias kes='ssh root@100.118.205.79 pct enter 137'     # kestra
alias nek='ssh root@100.118.205.79 pct enter 138'     # neko
alias aw='ssh root@100.118.205.79 pct enter 300'      # agent-workstation

# === ANDROID PHONES (ADB over Tailscale) ===
alias b='adb connect 100.104.84.29:5555 && adb -s 100.104.84.29:5555 shell'  # bojana
alias bs='adb -s 100.104.84.29:5555 shell "run-as com.termux sh"'             # bojana shell
alias d='adb connect DEKI_IP:5555 && adb shell'      # deki (fill IP)

# === SMART COMMANDS ===
# One-letter infrastructure overview
alias i='echo "=== INFRASTRUCTURE STATUS ===" && \
         echo "Proxmox:" && ssh root@100.118.205.79 "pct list | grep running" && \
         echo "" && echo "Android:" && adb devices'

# Jump to unified-dotfiles
alias dot='cd ~/unified-dotfiles'

# Quick sync from GitHub
alias sync='cd ~/unified-dotfiles && git pull && bash install.sh'

# Deploy to all devices
alias deploy='cd ~/unified-dotfiles && git push && echo "Pushed! Devices will auto-sync."'

# Show this help
alias elite='cat ~/.elite-ssh-config | grep "^alias" | sed "s/alias //" | column -t -s "#"'
