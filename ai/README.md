# AI

Global AI agent config for the machine. Installed into `~/.codex/` and `~/.claude/` by `make agents` from the repo root.

| File | What it is | Installed at |
|---|---|---|
| [AGENTS.md](AGENTS.md) | Universal rules: git identity, no AI attribution, Conventional Commits, branch naming, language, PR conventions (mermaid for complex behaviour). | `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` (both symlinks back to this file) |

The dotfiles repo itself also carries a project-specific [AGENTS.md](../AGENTS.md) at its root for scopes and Makefile pointers — that one is **not** installed globally.

CLIs and desktop apps for AI tooling are installed by the root [Brewfile](../Brewfile):
- `claude` (desktop)
- `claude-code` (CLI)
- `codex` (CLI)
- `codeburn` (menubar)
