# =============================================================================
# Exports — non-sensitive environment variables
# Secrets and tokens go in ~/.zshrc.local (gitignored)
# =============================================================================

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Language / locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Go
export GOPATH="$HOME/go"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"

# nvm
export NVM_DIR="$HOME/.nvm"

# PATH — assembled in one place to avoid duplicates
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$BUN_INSTALL/bin"
  "$ANDROID_HOME/emulator"
  "$ANDROID_HOME/platform-tools"
  "$GOPATH/bin"
  "$HOME/.ballerina/ballerina-home/bin"
  $path
)
export PATH

# SDKMAN init (must come after PATH)
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# nvm init
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
