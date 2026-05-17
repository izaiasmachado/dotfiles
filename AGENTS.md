# AGENTS.md

Default guidance for AI coding agents (Codex, Claude Code, Copilot) working on Izaias's repositories.

This file lives in the [dotfiles](https://github.com/izaiasmachado/dotfiles) repo and is installed as the global agent config via `make agents`:

- `~/.codex/AGENTS.md` → this file (read by Codex CLI on every session)
- `~/.claude/CLAUDE.md` → this file (read by Claude Code on every session)

The rules below apply to **every repo** Codex/Claude touch. A repo can override or extend them with its own `AGENTS.md` / `CLAUDE.md`.

## Git identity

Always commit as:

- **Name:** `Izaias Machado`
- **Email:** `izaiasmachado.dev@gmail.com`

Verify before committing:

```bash
git config user.name   # → Izaias Machado
git config user.email  # → izaiasmachado.dev@gmail.com
```

## No AI attribution

Do **not** add any AI signature to commits or pull requests:

- `Co-Authored-By: Claude <noreply@anthropic.com>` — not allowed
- `Co-Authored-By: Codex …` — not allowed
- "Generated with Claude Code" / "Generated with Codex" footers — not allowed
- Mentions of "AI", "Claude", "Codex", "Copilot" in commit messages or PR bodies — not allowed

Commits and PRs should read as if written by Izaias.

## Commit messages — Conventional Commits

Format: `type(scope): short summary in the imperative`

**Allowed types:** `feat`, `fix`, `chore`, `docs`, `refactor` (also `test`, `perf`, `style`, `build`, `ci` if relevant).

**Scope** is the touched area of the codebase — use whatever module names are conventional in the current repo. From this dotfiles repo's history: `brew`, `zsh`, `macos`, `iterm2`, `skills`, `claude`, `git`. Drop the scope only when the change spans the whole repo.

**Examples (from the dotfiles repo):**

```
feat(brew): add tmux and pearcleaner
fix(macos): skip universalaccess tweaks when Full Disk Access is missing
chore(skills): more descriptive display_name for glab skill
docs(zsh): use Option (⌥) instead of Alt for macOS keybindings
refactor(skills): copy via rsync instead of symlink
chore(brew): rename tailscale cask to tailscale-app
```

**Rules:**

- Imperative mood: `add`, not `added` / `adds`.
- Lowercase after the colon.
- No trailing period.
- Keep the subject ≤ 72 characters.
- Body (optional) explains the *why*, separated by a blank line.

## Branch names

`<type>/<short-kebab-summary>`

Allowed prefixes:

| Prefix | Use for |
|---|---|
| `feature/` | New functionality |
| `fix/` | Bug fixes |
| `chore/` | Maintenance, deps, renames, non-functional cleanup |
| `docs/` | Documentation-only changes |
| `refactor/` | Restructuring without behavior change |

Examples: `feature/add-glab-skill`, `fix/macos-permissions`, `docs/ssh-guides`, `chore/rename-tailscale-cask`, `refactor/skills-rsync`.

> Note: some older branches in `git log` use `feat/` (the conventional-commits short form). Going forward, **always use `feature/`** for new branches — do not mirror the older `feat/` prefix.

## Language

Default to **English** for commits, branch names, and PR titles/descriptions.

Switch to **Portuguese** only when the project's existing history is already in Portuguese (check `git log` — if commits and PRs are in PT, match it). Never mix languages within a single commit or PR.

## Pull requests

- Title follows the same Conventional Commits format as the squashed commit.
- Description focuses on *why* and *what changed*, in the language used by the rest of the project.
- No AI footer, no co-author trailer.
- **Include a Mermaid diagram** in the PR description whenever the change introduces non-trivial control flow, state transitions, or interaction between multiple components. Use a fenced ```` ```mermaid ```` block and pick the diagram type that fits the behaviour:
  - `flowchart` — branching logic, request paths, decision trees.
  - `sequenceDiagram` — cross-component calls, async flows, API exchanges.
  - `stateDiagram-v2` — state machines, lifecycle changes.
  - `erDiagram` — new tables, schema changes, foreign-key relationships.
  - `classDiagram` — non-trivial class/type hierarchies.

  Skip the diagram for trivial changes (renames, single-line fixes, doc tweaks, dependency bumps). Example for a request path:

  ````markdown
  ```mermaid
  flowchart LR
      Client --> API[/POST /orders/]
      API --> Validate{valid?}
      Validate -- no --> Reject[400]
      Validate -- yes --> DB[(orders)]
      DB --> Queue[[publish order.created]]
  ```
  ````
