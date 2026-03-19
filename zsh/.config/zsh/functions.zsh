# =============================================================================
# Shell Functions
# =============================================================================

# Create a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)  tar xjf "$1"   ;;
      *.tar.gz)   tar xzf "$1"   ;;
      *.tar.xz)   tar xJf "$1"   ;;
      *.bz2)      bunzip2 "$1"   ;;
      *.rar)      unrar x "$1"   ;;
      *.gz)       gunzip "$1"    ;;
      *.tar)      tar xf "$1"    ;;
      *.tbz2)     tar xjf "$1"   ;;
      *.tgz)      tar xzf "$1"   ;;
      *.zip)      unzip "$1"     ;;
      *.Z)        uncompress "$1" ;;
      *.7z)       7z x "$1"      ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Show top 10 most-used commands from history
topcmds() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
}

# Quick HTTP server in current directory
serve() {
  local port="${1:-8000}"
  echo "Serving at http://localhost:${port}"
  python3 -m http.server "$port"
}

# Show PATH entries one per line
path() {
  echo "$PATH" | tr ':' '\n'
}

# Git clone and cd into the repo
gclone() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# Find process by name
psg() {
  ps aux | grep "[${1:0:1}]${1:1}"
}
