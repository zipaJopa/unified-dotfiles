#!/bin/bash
# 📡 Phone Home - Sync with GitHub
# Pulls latest changes from GitHub and updates local dotfiles

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

cd "$DOTFILES_DIR" || exit 1

echo "📡 Phone Home - Syncing..."

# Stash local changes
if ! git diff-index --quiet HEAD --; then
    echo "💾 Stashing local changes..."
    git stash
    STASHED=1
fi

# Pull latest
echo "📥 Pulling from GitHub..."
if git pull --rebase; then
    echo "✅ Sync successful!"

    # Re-apply stash if we stashed
    if [ "$STASHED" = "1" ]; then
        echo "📤 Re-applying local changes..."
        git stash pop
    fi

    # Re-run install to update symlinks/files
    bash "$DOTFILES_DIR/install.sh"
else
    echo "❌ Sync failed!"
    exit 1
fi
