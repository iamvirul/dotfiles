# dotfiles

Personal macOS developer dotfiles for [@iamvirul](https://github.com/iamvirul), managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's inside

| Package | Contents |
|---------|----------|
| `zsh/` | `.zshrc`, `.zshenv`, `.zprofile`, modular config in `.config/zsh/` |
| `git/` | `.gitconfig`, global `.config/git/ignore` |
| `nvim/` | Neovim config (lazy.nvim, LSP, Telescope, Treesitter) |
| `bin/` | Personal scripts in `~/bin/` |
| `packages/` | `Brewfile` — all Homebrew formulae, casks, and VS Code extensions |

## Stack

- **Shell**: Zsh + [Oh My Zsh](https://ohmyz.sh/) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting, fzf
- **Editor**: [Neovim](https://neovim.io/) with lazy.nvim
- **Languages**: Go, Ballerina, PHP, Rust (via rustup), Bun
- **Terminal**: macOS Terminal / any ANSI-compatible terminal

## Install

```bash
# 1. Clone the repo
git clone https://github.com/iamvirul/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles

# 2. Run the installer
./install.sh

# 3. Restart shell
source ~/.zshrc
```

### What install.sh does

1. Installs [GNU Stow](https://www.gnu.org/software/stow/) if missing
2. Runs `brew bundle` to install all packages from `packages/Brewfile`
3. Uses `stow` to symlink each package into `$HOME`
4. Sets up fzf shell integration
5. Creates `~/.zshrc.local` for machine-specific secrets (not tracked)

### Dry run

```bash
./install.sh --dry-run
```

## Secrets / local config

Anything machine-specific or secret goes in `~/.zshrc.local`. This file is **gitignored** and sourced at the end of `.zshrc`.

```bash
# ~/.zshrc.local (example)
export UV_PUBLISH_TOKEN="pypi-..."
export AWS_PROFILE="personal"
```

## Updating

```bash
cd ~/Developer/dotfiles
git pull
./install.sh   # re-stow any new packages
```

## Structure

```
dotfiles/
├── git/
│   ├── .gitconfig
│   └── .config/git/ignore
├── zsh/
│   ├── .zshrc
│   ├── .zshenv
│   ├── .zprofile
│   └── .config/zsh/
│       ├── aliases.zsh
│       ├── exports.zsh
│       └── functions.zsh
├── nvim/
│   └── .config/nvim/       ← git submodule
├── bin/
│   └── bin/
├── packages/
│   └── Brewfile
└── install.sh
```

## Adding a new machine

1. Clone repo
2. `./install.sh`
3. Add machine-specific config to `~/.zshrc.local`
