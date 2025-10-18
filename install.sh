#!/bin/bash
# 🏠 Pavle's Unified Dotfiles Installer
# SAMO JAKO! 💪

set -e

REPO_URL="https://github.com/pavlebradic/unified-dotfiles.git"  # UPDATE THIS!
INSTALL_DIR="${1:-$HOME/.dotfiles}"

echo "🏠 UNIFIED DOTFILES INSTALLER"
echo "=============================="
echo ""

# Detect platform
if [ -d "/data/data/com.termux" ]; then
    PLATFORM="termux"
    echo "📱 Platform: Termux (Android)"
elif [ -f "/etc/lsb-release" ] && grep -q "Ubuntu\|Debian" /etc/lsb-release; then
    PLATFORM="linux"
    echo "🐧 Platform: Linux"
elif uname | grep -q "Darwin"; then
    PLATFORM="macos"
    echo "🍎 Platform: macOS"
else
    PLATFORM="unknown"
    echo "❓ Platform: Unknown (proceeding anyway)"
fi

echo ""

# Clone or update repo
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "📦 Updating existing dotfiles..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "📥 Cloning dotfiles..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo ""

# Platform-specific installation
case $PLATFORM in
    termux)
        echo "🤖 Installing Termux configs..."

        # Copy Termux files
        cp -r termux/.termux ~/
        cp -r termux/scripts ~/
        [ -f termux/.bashrc ] && cp termux/.bashrc ~/

        # Install agents
        cp -r agents ~/
        cp -r voice ~/

        # Make scripts executable
        chmod +x ~/scripts/*.sh
        chmod +x ~/agents/*.py 2>/dev/null || true

        echo "✅ Termux setup complete!"
        echo "   Start agents: ~/scripts/start_agent_system.sh"
        ;;

    linux)
        echo "🐧 Installing Linux configs..."

        # Symlink configs
        ln -sf "$INSTALL_DIR/configs/.gitconfig" ~/.gitconfig 2>/dev/null || true
        ln -sf "$INSTALL_DIR/configs/.tmux.conf" ~/.tmux.conf 2>/dev/null || true

        # Install scripts
        sudo mkdir -p /usr/local/bin
        sudo cp scripts/network/* /usr/local/bin/ 2>/dev/null || true
        sudo chmod +x /usr/local/bin/*.{sh,py} 2>/dev/null || true

        echo "✅ Linux setup complete!"
        ;;

    *)
        echo "⚠️  Platform-specific setup skipped"
        ;;
esac

echo ""
echo "📡 Setting up phone-home auto-sync..."

# Setup phone-home cron/boot
if [ "$PLATFORM" = "termux" ]; then
    # Termux: use termux-boot
    mkdir -p ~/.termux/boot
    cp phone-home/phone-home-daemon.sh ~/.termux/boot/
    chmod +x ~/.termux/boot/phone-home-daemon.sh
    echo "  ✅ Phone-home will start on boot"
else
    # Linux: use cron
    (crontab -l 2>/dev/null; echo "0 * * * * $INSTALL_DIR/phone-home/sync.sh") | crontab -
    echo "  ✅ Phone-home cron installed (hourly)"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "  - Review configs in: $INSTALL_DIR"
echo "  - Run sync: $INSTALL_DIR/phone-home/sync.sh"
echo "  - Check status: git -C $INSTALL_DIR status"
