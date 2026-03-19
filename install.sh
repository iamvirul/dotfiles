#!/usr/bin/env bash
# =============================================================================
# install.sh — Bootstrap dotfiles on a new machine
# Usage: ./install.sh [--dry-run]
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown argument: $arg" && exit 1 ;;
  esac
done

log()  { echo "[dotfiles] $*"; }
info() { echo "[dotfiles] INFO: $*"; }
warn() { echo "[dotfiles] WARN: $*"; }
die()  { echo "[dotfiles] ERROR: $*" >&2; exit 1; }

stow_package() {
  local pkg="$1"
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    warn "Package '$pkg' not found, skipping."
    return
  fi
  if $DRY_RUN; then
    info "DRY RUN — would stow: $pkg"
  else
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
    info "Stowed: $pkg"
  fi
}

# -----------------------------------------------------------------------------
# 1. Prerequisites
# -----------------------------------------------------------------------------
log "Checking prerequisites..."

if ! command -v brew &>/dev/null; then
  die "Homebrew not found. Install from https://brew.sh"
fi

if ! command -v stow &>/dev/null; then
  log "Installing GNU Stow..."
  $DRY_RUN || brew install stow
fi

# -----------------------------------------------------------------------------
# 2. Install Homebrew packages
# -----------------------------------------------------------------------------
if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
  log "Installing Homebrew packages..."
  $DRY_RUN || brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
fi

# -----------------------------------------------------------------------------
# 3. Stow dotfile packages
# -----------------------------------------------------------------------------
log "Symlinking dotfiles via GNU Stow..."

PACKAGES=(
  git
  zsh
  nvim
  bin
)

for pkg in "${PACKAGES[@]}"; do
  stow_package "$pkg"
done

# -----------------------------------------------------------------------------
# 4. Nvim submodule
# -----------------------------------------------------------------------------
if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
  log "Updating git submodules..."
  $DRY_RUN || git -C "$DOTFILES_DIR" submodule update --init --recursive
fi

# -----------------------------------------------------------------------------
# 5. FZF shell integration
# -----------------------------------------------------------------------------
if command -v fzf &>/dev/null && [[ ! -f "$HOME/.fzf.zsh" ]]; then
  log "Setting up fzf shell integration..."
  $DRY_RUN || "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

# -----------------------------------------------------------------------------
# 6. SDKMAN
# -----------------------------------------------------------------------------
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "Installing SDKMAN..."
  if ! $DRY_RUN; then
    curl -s "https://get.sdkman.io" | bash
    # Source SDKMAN so we can use sdk commands in this script
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  fi
else
  info "SDKMAN already installed, skipping."
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# -----------------------------------------------------------------------------
# 7. OpenJDK (via SDKMAN)
# -----------------------------------------------------------------------------
if command -v sdk &>/dev/null; then
  if ! sdk list java | grep -q "installed"; then
    log "Installing OpenJDK (latest LTS) via SDKMAN..."
    $DRY_RUN || sdk install java
  else
    info "OpenJDK already installed via SDKMAN, skipping."
  fi
else
  warn "sdk command not available — OpenJDK not installed. Re-run install.sh after a shell restart."
fi

# -----------------------------------------------------------------------------
# 8. Node.js / npm (via nvm)
# -----------------------------------------------------------------------------
if [[ ! -d "$HOME/.nvm" ]]; then
  log "Installing nvm..."
  if ! $DRY_RUN; then
    NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  fi
else
  info "nvm already installed, skipping."
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
fi

if command -v nvm &>/dev/null; then
  if ! nvm ls --no-colors | grep -q "default"; then
    log "Installing Node.js LTS via nvm..."
    if ! $DRY_RUN; then
      nvm install --lts
      nvm alias default 'lts/*'
    fi
  else
    info "Node.js already installed via nvm, skipping."
  fi
else
  warn "nvm command not available — Node.js not installed. Re-run install.sh after a shell restart."
fi

# -----------------------------------------------------------------------------
# 9. Local secrets template
# -----------------------------------------------------------------------------
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  log "Creating ~/.zshrc.local template for local secrets..."
  if ! $DRY_RUN; then
    cat > "$HOME/.zshrc.local" <<'EOF'
# =============================================================================
# ~/.zshrc.local — Machine-specific config and secrets
# NOT tracked in git. Keep secrets here.
# =============================================================================

# Example:
# export UV_PUBLISH_TOKEN="pypi-..."
# export AWS_PROFILE="personal"

# claude-mem (local path)
# alias claude-mem='bun "/path/to/worker-service.cjs"'
EOF
  fi
  info "Created ~/.zshrc.local — add your secrets there"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
log "Done! Restart your shell or run: source ~/.zshrc"
