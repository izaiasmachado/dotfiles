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
| `make all` | Runs everything: `brew` + `zsh` + `link` + `macos` + `iterm2` + `skills` + `claude` |
| `make brew` | Installs Homebrew (if needed) and runs `brew bundle` against `Brewfile` |
| `make zsh` | Installs oh-my-zsh and the custom plugins (`fzf-tab`, `zsh-autosuggestions`, `zsh-syntax-highlighting`) |
| `make link` | Symlinks `.zshrc` and `.gitignore_global` into `~`, and sets `git core.excludesfile` |
| `make macos` | Applies `defaults write` for Finder, Dock, and keyboard |
| `make iterm2` | Points iTerm2 at this repo's prefs folder (`iterm2/`) |
| `make skills` | Copies every folder under `skills/` into both `~/.codex/skills/` and `~/.claude/skills/` (via `rsync -a --delete`; repo is the source of truth) |
| `make claude` | Symlinks `claude/settings.json` into `~/.claude/settings.json` |

## Docs

| Guide | What it covers |
|-------|----------------|
| [docs/ssh-keys.md](docs/ssh-keys.md) | Generate an SSH key on a new Mac, load it into the keychain, register with GitHub/GitLab |
| [docs/ssh-remote-login.md](docs/ssh-remote-login.md) | Enable inbound SSH on a Mac, copy your key with `ssh-copy-id`, and harden it |
| [docs/zsh-autocomplete.md](docs/zsh-autocomplete.md) | Cheat-sheet for fzf-tab, autosuggestions, and the fzf keybindings (`Ctrl-R`, `Ctrl-T`, `⌥C`) |
| [docs/iterm2-sync.md](docs/iterm2-sync.md) | Sync iTerm2 UI changes back into the committed plist via [scripts/iterm2-sync.py](scripts/iterm2-sync.py), without runtime junk |
| [skills/README.md](skills/README.md) | Catalogue of every skill in this repo + convention for vendoring upstream skills |

## Layout

```
.
├── Brewfile               # Homebrew packages (CLI + casks)
├── Makefile               # setup targets
├── macos.sh               # macOS defaults
├── zsh/.zshrc             # shell config
├── git/.gitignore_global  # global gitignore (includes AI tooling folders)
├── iterm2/                # iTerm2 plist (load preferences from custom folder)
├── skills/                # Codex + Claude Code skills (rsync'd into ~/.codex/skills/ and ~/.claude/skills/)
├── claude/                # Claude Code user settings (~/.claude/settings.json)
├── docs/                  # SSH and other setup guides
├── scripts/               # helper scripts (iterm2-sync, …)
└── ai/                    # placeholder for AI configs (future phase)
```
