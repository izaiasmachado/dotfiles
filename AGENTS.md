# AGENTS.md — Dotfiles repo

Project-specific guidance for AI agents working on this dotfiles repo.

For Izaias's **global rules** (git identity, no AI attribution, Conventional Commits, branch naming, language, PR mermaid rule), see [ai/AGENTS.md](ai/AGENTS.md). That file is also installed at `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` via `make agents`, so the global rules apply to every repo on the machine — this repo just adds the dotfiles-specific bits below.

## Conventional-commits scopes for this repo

Use the touched area as the scope:

| Scope | What it covers |
|---|---|
| `brew` | [Brewfile](Brewfile), Homebrew packages |
| `zsh` | [zsh/.zshrc](zsh/.zshrc), oh-my-zsh plugins |
| `macos` | [macos.sh](macos.sh) `defaults write` tweaks |
| `iterm2` | [iterm2/](iterm2/) plist or the [iterm2-sync](skills/iterm2-sync/) script |
| `skills` | anything under [skills/](skills/) |
| `claude` | [claude/settings.json](claude/settings.json) or the `make claude` target |
| `agents` | [ai/AGENTS.md](ai/AGENTS.md) or the `make agents` target |
| `git` | [git/.gitignore_global](git/.gitignore_global) |
| `docs` | guides under [docs/](docs/) |
| `scripts` | helper scripts under [scripts/](scripts/) |

Drop the scope when the change spans the whole repo.

## Setup targets

When wiring something new into machine setup, add a `make` target in [Makefile](Makefile) and list it in `make all`. See the [README's Makefile table](README.md#makefile-targets) for the existing targets and pick a pattern that matches (symlink for single files like `make link` / `make claude` / `make agents`; rsync for directories like `make skills`).

## Path quoting in Makefile recipes

`$HOME` on this machine contains spaces (`/Volumes/SSD - Mac Mini M4 - Izaias/izaias-macmini`). When writing or editing make recipes, **always quote** `"$$HOME/..."` and `"$(PWD)/..."`. Unquoted paths split on spaces and fail with `mkdir: /Volumes/SSD: Permission denied` (or similar). Compare a correct target (`agents`, `claude`) with `link`/`skills` for the pattern.
