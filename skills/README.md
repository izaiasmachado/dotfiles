# Skills

Skills are small, self-contained packages of instructions (`SKILL.md`) and optional supporting scripts/configs that coding agents (Claude Code, Codex) load and trigger automatically based on the conversation. Each subdirectory here becomes one skill.

`make skills` rsyncs every directory under `skills/` into both `~/.codex/skills/` and `~/.claude/skills/`, so the same skill is available in both runtimes. The repo is the single source of truth — edits land here, then propagate to the runtimes on the next `make skills`.

## Catalogue

### Own skills

Skills authored in this repo for our specific workflow.

| Skill | What it does |
|---|---|
| [iterm2-sync](iterm2-sync/SKILL.md) | Walks the agent through capturing iTerm2 UI tweaks (colors, fonts, keymaps, hotkeys, dock behavior) back into the committed plist via `scripts/iterm2-sync.py`. Refuses to run while iTerm2 is alive and filters runtime noise (window positions, telemetry) so commits stay clean. |

### Vendor-supported skills

Skills copied from external projects. They live here as plain directories so `make skills` installs them with the same mechanism as our own. See [Vendor-supported skills convention](#vendor-supported-skills-convention) below for how we manage updates.

#### From [obra/superpowers](https://github.com/obra/superpowers)

A curated subset of Jesse @obra's Superpowers plugin — only the skills that universally improve any dev workflow.

| Skill | What it does |
|---|---|
| [brainstorming](brainstorming/SKILL.md) | Forces the agent to explore intent, requirements, and design before any creative work (new features, components, behavior changes). Eliminates premature implementation. |
| [writing-plans](writing-plans/SKILL.md) | Turns a spec or set of requirements into an explicit, reviewable implementation plan before code is touched. Emphasizes red/green TDD, YAGNI, DRY. |
| [test-driven-development](test-driven-development/SKILL.md) | Enforces the TDD cycle: write a failing test, make it pass, refactor — before any implementation code. |
| [systematic-debugging](systematic-debugging/SKILL.md) | Imposes a structured approach to bugs and unexpected behavior — read the actual evidence before proposing fixes, not the other way around. |
| [verification-before-completion](verification-before-completion/SKILL.md) | Required check before claiming work is done, fixed, or passing. Runs verification commands and confirms output before any "done" assertion. Evidence before claims, always. |
| [using-superpowers](using-superpowers/SKILL.md) | Meta-skill that primes the agent to actually look at the Skill catalogue at the start of every conversation, instead of jumping straight into work. |

## Vendor-supported skills convention

We **vendor** (copy) curated, high-value skills from upstream projects into this repo rather than relying on plugin marketplaces. Reasons:

1. **One install mechanism**: `make skills` already handles `skills/*`. No second pipeline for marketplaces, no Claude-vs-Codex split (Claude installs via `enabledPlugins` in `settings.json`, Codex needs a `config.toml` edit — vendoring sidesteps both).
2. **Reproducibility**: same files install the same way on every Mac, regardless of network access, marketplace availability, or upstream service changes.
3. **Auditability**: the exact text the agent sees is in git history. Upstream silent edits don't change agent behavior on our machines.
4. **Selective inclusion**: we pick the skills that fit our workflow instead of the full plugin (e.g., we vendored 6 of the 14 Superpowers skills).

Trade-off accepted: **upstream updates don't come for free**. When the upstream author improves a skill, we have to re-sync manually.

### How to update a vendored skill

For Superpowers (upstream cloned at `~/dev/plugins/plugins/superpowers/`):

```bash
# From repo root, for a single skill:
rsync -a --delete "$HOME/dev/plugins/plugins/superpowers/skills/<skill-name>/" "skills/<skill-name>/"

# Then review and commit:
git diff skills/<skill-name>/
git add skills/<skill-name>/
git commit -m "chore(skills): sync <skill-name> from upstream Superpowers"
```

For a full re-sync of every Superpowers-vendored skill, loop over the list above.

### Adding a new vendored skill

1. Copy the skill directory from upstream into `skills/<skill-name>/`.
2. Verify `SKILL.md` has a sensible `name` and `description` YAML frontmatter (both Claude Code and Codex use this).
3. Add a row in the **Vendor-supported skills** section above with a 1-line description.
4. Commit. Next `make skills` installs it on every Mac.

### Removing a vendored skill

1. `git rm -r skills/<skill-name>/`
2. Remove its row from the catalogue above.
3. Next `make skills` won't reinstall it. **However**, runtimes that previously had it installed still have the copy in `~/.codex/skills/` and `~/.claude/skills/` — `make skills` doesn't garbage-collect skills missing from the repo. Remove those manually if desired.
