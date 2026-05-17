---
name: glab-inline-mr-comments
description: Publish or troubleshoot inline GitLab merge request comments with `glab`, using the correct diff `position` metadata (`base_sha`, `start_sha`, `head_sha`, file path, and line). Use when Codex needs to create line-specific review comments on a GitLab MR, explain why a comment is not attaching to a line, or automate draft note creation and publishing through `glab api`.
---

# Glab Inline Mr Comments

## Overview

Use this skill when a GitLab review comment must be attached to a specific changed line in an MR.
The key rule is: GitLab inline comments need a valid diff `position`; `file + line` alone is not enough.

## Quick Start

Use the bundled script:

```bash
scripts/post_inline_comment.sh <project_ref> <mr_iid> <path> <line> <comment>
```

Example:

```bash
scripts/post_inline_comment.sh \
  coopedu-system/coopedu-admin \
  433 \
  'src/app/sistema/folhas/[id]/processamento/page.tsx' \
  784 \
  'Aqui a interface fala em TOTP, mas o ideal é padronizar para autenticação em duas etapas.'
```

By default the script:
- fetches the MR SHAs
- creates a `draft_note` with inline `position`
- publishes the draft immediately

Use `--no-publish` to keep the comment as draft.

## Required Position Fields

For a comment on an added or changed line in the new version of the file, send:

- `position[position_type]=text`
- `position[base_sha]=...`
- `position[start_sha]=...`
- `position[head_sha]=...`
- `position[new_path]=path/to/file`
- `position[new_line]=123`

For a removed line, use:

- `position[old_path]=path/to/file`
- `position[old_line]=123`

Do not mix `new_line` with `old_path/old_line` unless the GitLab diff actually requires both sides.

## Workflow

1. Resolve the GitLab project reference.
   Use the numeric project id if you already have it.
   Otherwise a path like `group/project` also works; the script URL-encodes it.
2. Fetch MR metadata.
   Read `diff_refs.base_sha`, `diff_refs.start_sha`, and `diff_refs.head_sha`.
3. Confirm the target line exists in the MR diff.
   If the line is not part of the current diff, GitLab will not attach the comment inline.
4. Create the inline comment as `draft_note`.
   This is more reliable on some GitLab instances than creating the discussion directly.
5. Publish drafts if the comment should become visible immediately.

## Manual API Pattern

Create draft note:

```bash
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
```

Publish drafts:

```bash
glab api \
  "projects/<project_ref>/merge_requests/<iid>/draft_notes/bulk_publish" \
  -X POST
```

## Troubleshooting

- If the comment appears as a general MR note, the `position` was invalid or the line is no longer in the current diff.
- If GitLab rejects the request, verify the current `diff_refs`; stale SHAs are a common cause.
- If `discussions` behaves inconsistently, prefer `draft_notes` then `bulk_publish`.
- If the file path contains special characters such as `[` and `]`, pass it as a quoted shell string.
- If the instance behaves oddly, inspect the returned JSON and confirm `position` is present after creation.

## Script

Use [`scripts/post_inline_comment.sh`](scripts/post_inline_comment.sh) for routine posting.
It supports:
- project path or numeric id
- automatic MR SHA lookup
- new-line comments
- old-line comments via `--old`
- optional `--no-publish`
