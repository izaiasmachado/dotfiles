---
name: gitlab-mr-reviews
description: Interact with GitLab merge request review discussions via `glab` — post inline (line-anchored) comments with the correct diff `position` metadata, list/filter discussions (optionally unresolved only), mark discussions as resolved, and reply to existing threads. Use whenever a Codex/Claude task involves leaving review feedback on a GitLab MR, triaging open discussions, resolving them after addressing the feedback, or threading replies into an existing discussion.
---

# GitLab MR Reviews

End-to-end toolkit for working with GitLab merge request discussions through `glab`. Covers four operations: **post inline**, **list**, **resolve**, **reply**.

## Overview

GitLab models MR feedback as **discussions**, each containing one or more **notes**. An inline (line-anchored) discussion has a `position` object with `base_sha`/`start_sha`/`head_sha` from the MR's diff refs, plus `new_path`/`new_line` (for added/changed lines) or `old_path`/`old_line` (for removed lines). General comments are also discussions but without a `position`.

Resolution state lives on the note: `resolved: true|false`, gated by `resolvable: true|false`. Only inline discussions are resolvable.

All four scripts URL-encode the project reference (so `group/project` works the same as a numeric ID) and let `glab` handle auth.

## Scripts

| Script | What it does |
|---|---|
| [scripts/post_inline_comment.sh](scripts/post_inline_comment.sh) | Resolves MR diff SHAs, creates a `draft_note` with full `position` metadata, publishes it. Supports `--old` for removed-line comments and `--no-publish` to keep as draft. |
| [scripts/list_discussions.sh](scripts/list_discussions.sh) | Paginates all resolvable discussions on the MR and prints `<id> [resolved\|OPEN] @author file:line` + first body line. `--unresolved` filters to only open discussions. |
| [scripts/resolve_discussion.sh](scripts/resolve_discussion.sh) | Marks a discussion as resolved via `PUT discussions/{id}?resolved=true`. |
| [scripts/reply_to_discussion.sh](scripts/reply_to_discussion.sh) | Adds a note to an existing discussion (threaded reply). |

## Common workflows

### 1. Post a line-anchored review comment

```bash
scripts/post_inline_comment.sh <project_ref> <mr_iid> <path> <line> <comment>
```

Example:

```bash
scripts/post_inline_comment.sh \
  coopedu-system/coopedu-admin 433 \
  'src/app/sistema/folhas/[id]/processamento/page.tsx' 784 \
  'Aqui a interface fala em TOTP, mas o ideal é padronizar para autenticação em duas etapas.'
```

For a comment on a removed line, add `--old`. To keep as draft instead of publishing immediately, add `--no-publish`.

### 2. Triage open discussions

```bash
scripts/list_discussions.sh --unresolved <project_ref> <mr_iid>
```

Returns each open discussion's id, author, file:line, and first body line. Use the ids to drive the next two operations.

### 3. Resolve after addressing feedback

```bash
scripts/resolve_discussion.sh <project_ref> <mr_iid> <discussion_id>
```

### 4. Reply to a reviewer's note

```bash
scripts/reply_to_discussion.sh <project_ref> <mr_iid> <discussion_id> 'Boa observação, ajustei.'
```

**Only reply when the user explicitly asks you to.** Don't auto-reply just because there's an open discussion.

## Required position fields (for `post_inline_comment.sh`)

For a comment on an added or changed line in the new version of the file:

- `position[position_type]=text`
- `position[base_sha]=...`
- `position[start_sha]=...`
- `position[head_sha]=...`
- `position[new_path]=path/to/file`
- `position[new_line]=123`

For a removed line, swap to:

- `position[old_path]=path/to/file`
- `position[old_line]=123`

Don't mix `new_line` with `old_path/old_line` unless the GitLab diff genuinely shows both sides. The script does this automatically based on `--old`.

## Manual API patterns

When the wrapper scripts don't cover an edge case, fall back to `glab api`:

```bash
# Create draft note (inline):
glab api \
  "projects/<project_ref>/merge_requests/<iid>/draft_notes" \
  -X POST \
  --form note='Your comment' \
  --form 'position[position_type]=text' \
  --form 'position[base_sha]=BASE_SHA' \
  --form 'position[start_sha]=START_SHA' \
  --form 'position[head_sha]=HEAD_SHA' \
  --form 'position[new_path]=path/to/file.tsx' \
  --form 'position[new_line]=784'

# Publish all drafts:
glab api \
  "projects/<project_ref>/merge_requests/<iid>/draft_notes/bulk_publish" \
  -X POST

# List discussions:
glab api "projects/<project_ref>/merge_requests/<iid>/discussions?per_page=100" --paginate

# Resolve:
glab api "projects/<project_ref>/merge_requests/<iid>/discussions/<id>?resolved=true" -X PUT

# Reply:
glab api "projects/<project_ref>/merge_requests/<iid>/discussions/<id>/notes" \
  -X POST --form body='Reply text'
```

## Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| Comment appears as a general MR note instead of inline | `position` was invalid or the line is no longer in the current diff. Re-fetch `diff_refs` and try again. |
| GitLab rejects the request | Stale SHAs — diff was force-pushed. Re-run `post_inline_comment.sh`; it always re-fetches the SHAs. |
| `list_discussions.sh` shows nothing on an MR with comments | Those comments are general (non-inline) — they aren't resolvable, so the script skips them. Use raw `glab api .../discussions` to see everything. |
| File path with `[`/`]` rejected | Quote the path as a shell string; the script passes it as-is to `glab`. |
| Reply ends up creating a new discussion | You used `/notes` on the MR root, not `/discussions/<id>/notes`. Use `reply_to_discussion.sh`. |
| Anything weird | Inspect the raw response: `glab api '...' | jq .`. Confirm `position` is present after creation and `diff_refs` match the current MR head. |
