#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — One-liner setup for a new Mac, no cloning required
#
# Run with:
#   curl -fsSL https://raw.githubusercontent.com/iamvirul/dotfiles/main/bootstrap.sh | bash
# =============================================================================

set -euo pipefail

DOTFILES_REPO="https://github.com/iamvirul/dotfiles.git"
DOTFILES_DIR="$HOME/Developer/dotfiles"

echo "[dotfiles] Starting bootstrap..."

# Install Xcode CLT first (git requires it)
if ! xcode-select -p &>/dev/null; then
  echo "[dotfiles] Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

# Install Homebrew if missing (git may not be available yet on fresh Mac)
if ! command -v brew &>/dev/null; then
  echo "[dotfiles] Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Ensure git is available
if ! command -v git &>/dev/null; then
  echo "[dotfiles] Installing git..."
  brew install git
fi

# Clone dotfiles repo
if [[ -d "$DOTFILES_DIR" ]]; then
  echo "[dotfiles] Dotfiles already cloned, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "[dotfiles] Cloning dotfiles..."
  mkdir -p "$HOME/Developer"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Hand off to install.sh
echo "[dotfiles] Running install.sh..."
bash "$DOTFILES_DIR/install.sh" "$@"
