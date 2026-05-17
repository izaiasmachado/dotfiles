# Skills

Skills are small, self-contained packages of instructions (`SKILL.md`) and optional supporting scripts/configs that coding agents (Claude Code, Codex) load and trigger automatically based on the conversation. Each subdirectory here becomes one skill.

`make skills` rsyncs every directory under `skills/` into both `~/.codex/skills/` and `~/.claude/skills/`, so the same skill is available in both runtimes. The repo is the single source of truth — edits land here, then propagate to the runtimes on the next `make skills`.

## Catalogue

### Own skills

Skills authored in this repo for our specific workflow.

| Skill | What it does |
|---|---|
| [gitlab-mr-reviews](gitlab-mr-reviews/SKILL.md) | End-to-end toolkit for GitLab MR review discussions via `glab`: post line-anchored inline comments with diff `position` metadata, list/filter discussions (optionally `--unresolved`), resolve discussions, reply to threads. |
| [github-pr-reviews](github-pr-reviews/SKILL.md) | End-to-end toolkit for GitHub PR review threads via `gh`: post line-anchored inline comments tied to the PR head commit, list/filter review threads (GraphQL, optionally `--unresolved`), resolve threads, reply to comments. |

## Vendor-supported skills convention

We **vendor** (copy) curated, high-value skills from upstream projects into this repo rather than relying on plugin marketplaces. Reasons:

1. **One install mechanism**: `make skills` already handles `skills/*`. No second pipeline, no Claude-vs-Codex split (Claude installs via `enabledPlugins` in `settings.json`, Codex needs a `config.toml` edit — vendoring sidesteps both).
2. **Reproducibility**: same files install the same way on every Mac.
3. **Auditability**: the exact text the agent sees is in git history. Upstream silent edits don't change agent behavior on our machines.
4. **Selective inclusion**: we pick the skills that fit our workflow instead of importing the full plugin.

Trade-off accepted: **upstream updates don't come for free**. When the upstream author improves a skill, we have to re-sync manually.

### How to update a vendored skill

```bash
# From repo root, for a single skill:
rsync -a --delete "<upstream-path>/<skill-name>/" "skills/<skill-name>/"

# Then review and commit:
git diff skills/<skill-name>/
git add skills/<skill-name>/
git commit -m "chore(skills): sync <skill-name> from upstream"
```

### Adding a new vendored skill

1. Copy the skill directory from upstream into `skills/<skill-name>/`.
2. Verify `SKILL.md` has a sensible `name` and `description` YAML frontmatter (both Claude Code and Codex use this).
3. Add a row in the catalogue above (under a "Vendor-supported skills" section grouped by upstream source) with a 1-line description.
4. Commit. Next `make skills` installs it on every Mac.

### Removing a vendored skill

1. `git rm -r skills/<skill-name>/`
2. Remove its row from the catalogue.
3. Next `make skills` won't reinstall it. **However**, runtimes that previously had it installed still have the copy in `~/.codex/skills/` and `~/.claude/skills/` — `make skills` doesn't garbage-collect skills missing from the repo. Remove those manually if desired.

## Future considerations

### Single-source skill metadata (deferred)

Today, two files carry skill metadata for the two runtimes:

- `SKILL.md` frontmatter (`name`, `description`) — read by **both** Claude Code and Codex; this is what drives auto-triggering.
- `agents/openai.yaml` — read **only by Codex** for cosmetic UI fields (`display_name`, `short_description`, `default_prompt`). Optional.

Claude Code has **no equivalent** of `agents/openai.yaml` — its skill listing uses the `name` and `description` from `SKILL.md` directly, no separate per-vendor metadata file.

A future refactor could introduce a single `skill.yaml` per skill (slug, display name, descriptions, default prompt) and a build script that emits both `SKILL.md` frontmatter and `agents/openai.yaml`. **We deliberately didn't build this yet** because:

1. **Volume is too small to justify it.** Few own skills, ~4 lines of duplication each.
2. **Vendored skills don't fit the model.** Upstream skills arrive with hand-authored `SKILL.md`. Forcing them through a generator means either rewriting upstream content (loses `rsync -a --delete` syncs) or skipping vendored skills (loses the consistency that motivated it).
3. **Generated files in git are a footgun.** Someone edits the generated `SKILL.md`, the next build wipes it.
4. **No third runtime yet.** Only Claude + Codex today. A third runtime with its own format is the inflection point.

**Revisit when:** 5+ own skills exist, OR a third runtime with its own metadata format is in the picture.
