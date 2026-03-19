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
- **Languages**: Go, Ballerina, PHP, Rust (via rustup), Bun, Node.js (via nvm), Java (via SDKMAN)
- **Container**: Rancher Desktop
- **Terminal**: macOS Terminal / any ANSI-compatible terminal

## Fresh Mac Setup (One-liner)

Open Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/iamvirul/dotfiles/main/bootstrap.sh | bash
```

That's it. No cloning, no manual steps.

### What it installs — in order

| Step | Tool |
|------|------|
| 1 | Xcode Command Line Tools |
| 2 | Homebrew |
| 3 | GNU Stow |
| 4 | All Brewfile packages (neovim, gh, fzf, go, rancher, claude…) |
| 5 | Oh My Zsh |
| 6 | zsh-autosuggestions + zsh-syntax-highlighting |
| 7 | Powerlevel10k theme |
| 8 | Dotfile symlinks via stow |
| 9 | Git submodules |
| 10 | fzf shell integration |
| 11 | Rust (rustup) |
| 12 | Bun |
| 13 | SDKMAN |
| 14 | OpenJDK LTS |
| 15 | nvm + Node.js LTS |
| 16 | Claude Code CLI |
| 17 | `~/.zshrc.local` secrets template |

### Dry run

```bash
curl -fsSL https://raw.githubusercontent.com/iamvirul/dotfiles/main/bootstrap.sh | bash -s -- --dry-run
```

## Manual Install (if already have git/brew)

```bash
git clone https://github.com/iamvirul/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
./install.sh
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
./install.sh
```

## Structure

```
dotfiles/
├── bootstrap.sh              ← one-liner entry point
├── install.sh                ← full installer
├── packages/
│   └── Brewfile
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
│   └── .config/nvim/         ← git submodule
└── bin/
    └── bin/
```
