#!/bin/bash
# UNIFIED DOTFILES INSTALLER - Cross Platform

PLATFORM="unknown"
if [ -n "$TERMUX_VERSION" ]; then
    PLATFORM="termux"
elif [ "$(uname)" = "Linux" ]; then
    PLATFORM="linux"
fi

echo "🚀 Installing on: $PLATFORM"

case $PLATFORM in
    termux)
        # Termux installation
        mkdir -p ~/.termux
        cp -r termux/.termux/* ~/.termux/
        cp configs/elite-ssh.sh ~/.elite-ssh-config
        
        # Load shortcuts
        if ! grep -q "elite-ssh-config" ~/.bashrc; then
            echo "source ~/.elite-ssh-config" >> ~/.bashrc
        fi
        
        # Reload Termux settings
        termux-reload-settings 2>/dev/null || echo "⚠️  Restart Termux to apply extra-keys"
        
        echo "✅ Termux setup complete!"
        echo "📱 Restart Termux app for extra-keys"
        ;;
        
    linux)
        # Linux installation (WSL, servers, LXC)
        cp configs/elite-ssh.sh ~/.elite-ssh-config
        
        if ! grep -q "elite-ssh-config" ~/.bashrc; then
            echo "source ~/.elite-ssh-config" >> ~/.bashrc
        fi
        
        source ~/.bashrc 2>/dev/null || true
        echo "✅ Linux setup complete!"
        ;;
        
    *)
        echo "❌ Unknown platform!"
        exit 1
        ;;
esac

echo ""
echo "🎯 Type 'elite' to see all shortcuts!"
