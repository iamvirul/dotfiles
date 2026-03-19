# =============================================================================
# ~/.zshrc — Main Zsh configuration
# Managed via dotfiles: https://github.com/iamvirul/dotfiles
# =============================================================================

# --- Powerlevel10k instant prompt (must be near top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# --- Powerlevel10k config ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Modular config ---
for config_file in "$HOME/.config/zsh"/*.zsh; do
  source "$config_file"
done

# --- Key bindings ---
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# --- FZF ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- Bun completions ---
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# --- Local overrides (secrets, machine-specific config — not tracked in git) ---
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
