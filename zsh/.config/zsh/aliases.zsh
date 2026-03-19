# =============================================================================
# Aliases
# =============================================================================

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# --- Listing ---
alias ls='ls --color=auto'
alias ll='ls -lhF'
alias la='ls -lahF'
alias lt='ls -lhFt'          # sort by modification time

# --- Git ---
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git stash'
alias grb='git rebase'

# --- Editor ---
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# --- Utilities ---
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias cat='bat --paging=never' 2>/dev/null || true   # use bat if available
alias top='htop' 2>/dev/null || true                  # use htop if available

# --- macOS ---
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO && killall Finder'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias brewup='brew update && brew upgrade && brew cleanup'

# --- Dotfiles ---
alias dotfiles='cd ~/Developer/dotfiles'
alias zshrc='$EDITOR ~/.zshrc'
alias reload='source ~/.zshrc && echo "Shell reloaded"'
