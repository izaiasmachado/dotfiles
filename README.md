# Dotfiles — Mac startup

Complete setup to configure a Mac from scratch: packages (Homebrew), shell (zsh), git, macOS defaults, and iTerm2 profile.

## Requirements

- macOS (Apple Silicon or Intel)
- Xcode Command Line Tools: `xcode-select --install`

## Usage

```bash
git clone <repo> ~/dev/dotfiles
cd ~/dev/dotfiles
make all
```

## Makefile targets

| Target | What it does |
|--------|--------------|
| `make all` | Runs everything: `brew` + `zsh` + `link` + `macos` + `iterm2` + `skills` |
| `make brew` | Installs Homebrew (if needed) and runs `brew bundle` against `Brewfile` |
| `make zsh` | Installs oh-my-zsh and the custom plugins (`fzf-tab`, `zsh-autosuggestions`, `zsh-syntax-highlighting`) |
| `make link` | Symlinks `.zshrc` and `.gitignore_global` into `~`, and sets `git core.excludesfile` |
| `make macos` | Applies `defaults write` for Finder, Dock, and keyboard |
| `make iterm2` | Points iTerm2 at this repo's prefs folder (`iterm2/`) |
| `make skills` | Symlinks every folder under `skills/` into `~/.codex/skills/` |

## Layout

```
.
├── Brewfile               # Homebrew packages (CLI + casks)
├── Makefile               # setup targets
├── macos.sh               # macOS defaults
├── zsh/.zshrc             # shell config
├── git/.gitignore_global  # global gitignore (includes AI tooling folders)
├── iterm2/                # iTerm2 plist (load preferences from custom folder)
├── skills/                # Codex skills (symlinked into ~/.codex/skills/)
└── ai/                    # placeholder for AI configs (future phase)
```
