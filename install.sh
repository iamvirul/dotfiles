#!/usr/bin/env bash
# =============================================================================
# install.sh — Bootstrap dotfiles on a new Mac from scratch
# Usage: ./install.sh [--dry-run]
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

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

run() {
  if $DRY_RUN; then
    info "DRY RUN — would run: $*"
  else
    "$@"
  fi
}

stow_package() {
  local pkg="$1"
  if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
    warn "Package '$pkg' not found, skipping."
    return
  fi
  if $DRY_RUN; then
    info "DRY RUN — would stow: $pkg"
  else
    # Back up any conflicting files before stowing
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg" 2>/dev/null || {
      warn "Conflict detected for '$pkg' — backing up and retrying..."
      stow --dir="$DOTFILES_DIR" --target="$HOME" --adopt "$pkg"
      git -C "$DOTFILES_DIR" checkout -- "$pkg"
      stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
    }
    info "Stowed: $pkg"
  fi
}

# =============================================================================
# 1. Xcode Command Line Tools
# =============================================================================
log "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools..."
  run xcode-select --install
  # Wait for installation to complete
  until xcode-select -p &>/dev/null; do sleep 5; done
  info "Xcode CLT installed."
else
  info "Xcode CLT already installed."
fi

# =============================================================================
# 2. Homebrew
# =============================================================================
log "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script (Apple Silicon path)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  info "Homebrew already installed."
fi

# =============================================================================
# 3. GNU Stow
# =============================================================================
if ! command -v stow &>/dev/null; then
  log "Installing GNU Stow..."
  run brew install stow
fi

# =============================================================================
# 4. Homebrew packages (Brewfile)
# =============================================================================
if [[ -f "$DOTFILES_DIR/packages/Brewfile" ]]; then
  log "Installing Homebrew packages..."
  run brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
fi

# =============================================================================
# 5. Oh My Zsh
# =============================================================================
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing Oh My Zsh..."
  run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  info "Oh My Zsh already installed."
fi

# =============================================================================
# 6. Zsh plugins (autosuggestions + syntax highlighting)
# =============================================================================
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  log "Installing zsh-autosuggestions..."
  run git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  info "zsh-autosuggestions already installed."
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  log "Installing zsh-syntax-highlighting..."
  run git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  info "zsh-syntax-highlighting already installed."
fi

# =============================================================================
# 7. Powerlevel10k theme
# =============================================================================
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  log "Installing Powerlevel10k..."
  run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
else
  info "Powerlevel10k already installed."
fi

# =============================================================================
# 8. Stow dotfile packages
# =============================================================================
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

# =============================================================================
# 9. Git submodules (nvim config etc.)
# =============================================================================
if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
  log "Updating git submodules..."
  run git -C "$DOTFILES_DIR" submodule update --init --recursive
fi

# =============================================================================
# 10. FZF shell integration
# =============================================================================
if command -v fzf &>/dev/null && [[ ! -f "$HOME/.fzf.zsh" ]]; then
  log "Setting up fzf shell integration..."
  run "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

# =============================================================================
# 11. Rust (rustup)
# =============================================================================
if ! command -v rustup &>/dev/null; then
  log "Installing Rust via rustup..."
  run curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  source "$HOME/.cargo/env"
else
  info "Rust already installed."
fi

# =============================================================================
# 12. Bun
# =============================================================================
if ! command -v bun &>/dev/null; then
  log "Installing Bun..."
  run curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
else
  info "Bun already installed."
fi

# =============================================================================
# 13. SDKMAN
# =============================================================================
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "Installing SDKMAN..."
  run curl -s "https://get.sdkman.io" | bash
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
else
  info "SDKMAN already installed."
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# =============================================================================
# 14. OpenJDK (via SDKMAN)
# =============================================================================
if command -v sdk &>/dev/null; then
  if ! sdk list java | grep -q "installed"; then
    log "Installing OpenJDK (latest LTS) via SDKMAN..."
    run sdk install java
  else
    info "OpenJDK already installed via SDKMAN."
  fi
else
  warn "sdk not available — re-run install.sh after a shell restart to install OpenJDK."
fi

# =============================================================================
# 15. nvm + Node.js
# =============================================================================
if [[ ! -d "$HOME/.nvm" ]]; then
  log "Installing nvm..."
  if ! $DRY_RUN; then
    NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  fi
else
  info "nvm already installed."
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
    info "Node.js already installed via nvm."
  fi
else
  warn "nvm not available — re-run install.sh after a shell restart to install Node.js."
fi

# =============================================================================
# 16. Claude Code CLI
# =============================================================================
if ! command -v claude &>/dev/null; then
  log "Installing Claude Code CLI..."
  run npm install -g @anthropic-ai/claude-code
else
  info "Claude Code CLI already installed."
fi

# =============================================================================
# 17. Local secrets template
# =============================================================================
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  log "Creating ~/.zshrc.local for local secrets..."
  if ! $DRY_RUN; then
    cat > "$HOME/.zshrc.local" <<'EOF'
# =============================================================================
# ~/.zshrc.local — Machine-specific config and secrets (not tracked in git)
# =============================================================================

# export UV_PUBLISH_TOKEN="pypi-..."
# export AWS_PROFILE="personal"
# alias claude-mem='bun "/path/to/worker-service.cjs"'
EOF
  fi
  info "Created ~/.zshrc.local — add your secrets there."
fi

# =============================================================================
# Done
# =============================================================================
echo ""
log "All done! Open a new terminal tab or run: exec zsh"
