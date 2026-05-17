# Installing Superpowers

[Superpowers](https://github.com/obra/superpowers) is a curated set of skills by Jesse (@obra) that gives a coding agent a complete software-development workflow: brainstorming → planning → TDD → subagent-driven execution → verification → code review. It auto-triggers when relevant, so there's no extra step beyond installing it.

We install it via the official plugin marketplaces rather than vendoring the skills into this repo, so updates from upstream come for free.

## Claude Code

```bash
# Inside Claude Code:
/plugin install superpowers@claude-plugins-official
```

The plugin is in the [official Claude marketplace](https://claude.com/plugins/superpowers), so no extra marketplace registration is needed.

## Codex

Codex doesn't have a one-line CLI install. The upstream approach is to tell Codex to follow the install doc:

```
Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.codex/INSTALL.md
```

That script clones the skills under `~/.codex/skills/superpowers/` and wires up `~/.codex/AGENTS.md`. See the full upstream guide at [obra/superpowers/docs/README.codex.md](https://github.com/obra/superpowers/blob/main/docs/README.codex.md).

## What you get

14 skills covering the full workflow. Each one auto-triggers based on conversational context — no manual selection needed.

| Skill | When it fires |
|---|---|
| `brainstorming` | Before any creative work — explores intent before code |
| `dispatching-parallel-agents` | 2+ independent tasks without shared state |
| `executing-plans` | Running a written plan in a separate session |
| `finishing-a-development-branch` | Implementation done, choosing merge/PR/cleanup |
| `receiving-code-review` | Got feedback — verify before implementing blindly |
| `requesting-code-review` | Major feature done, before merging |
| `subagent-driven-development` | Executing plans with independent tasks in current session |
| `systematic-debugging` | Any bug / failure, before proposing fixes |
| `test-driven-development` | Before writing implementation code |
| `using-git-worktrees` | Need isolation from current workspace |
| `using-superpowers` | Triggers automatic skill discovery every conversation |
| `verification-before-completion` | Before claiming "done" |
| `writing-plans` | Have a spec, before touching code |
| `writing-skills` | Creating/editing skills |

## Disabling individual skills

If a specific skill gets in the way, disable it without uninstalling the plugin via `skillOverrides` in `~/.claude/settings.json`:

```json
{
  "skillOverrides": {
    "dispatching-parallel-agents": "off",
    "using-git-worktrees": "name-only"
  }
}
```

Values: `on` (default), `name-only` (still listed, no description sent to model), `user-invocable-only` (hidden from model, still callable via `/skill-name`), `off` (fully hidden).

## Why not vendor the skills

Copying the 14 skills into `skills/` would work but means:
- We lose upstream updates from Jesse without manual re-sync
- Repo size grows (each skill has its own SKILL.md + supporting scripts/docs)
- Two sources of truth (vendored vs upstream) for the same content

The plugin marketplace approach keeps this repo focused on **our** skills and configs while delegating the curated workflow to its maintainer.
