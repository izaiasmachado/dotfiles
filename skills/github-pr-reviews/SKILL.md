---
name: github-pr-reviews
description: Interact with GitHub pull request review threads via `gh` — post inline (line-anchored) review comments anchored to the PR's head commit, list/filter review threads (optionally unresolved only), mark threads as resolved, and reply to existing threads. Use whenever a Codex/Claude task involves leaving review feedback on a GitHub PR, triaging open review threads, resolving them after addressing the feedback, or threading replies into an existing conversation.
---

# GitHub PR Reviews

End-to-end toolkit for working with GitHub pull request review threads through `gh`. Covers four operations: **post inline**, **list**, **resolve**, **reply**.

## Overview

GitHub models PR feedback as **review threads**, each containing one or more **review comments**. An inline comment is anchored to a specific commit (the PR's head SHA when posted), a file `path`, and a `line` number on a `side` (`RIGHT` = head/new, `LEFT` = base/old). Multi-line comments add `start_line`.

Thread resolution is **not exposed via the REST API** — it lives only in GraphQL (`reviewThreads.isResolved` and the `resolveReviewThread` mutation). The list/resolve scripts use GraphQL for this reason; the post/reply scripts use REST.

All scripts let `gh` handle auth (gh's stored token).

## Identifier types

GitHub PR comments have **two** ids that look completely different and are used in different APIs:

- **databaseId** (integer, e.g. `1234567890`) — REST. Used to reply to a comment.
- **thread node id** (opaque base64-ish string, e.g. `PRRT_kwDOABCxyz...`) — GraphQL. Used to resolve a thread.

`list_comments.sh` prints both: thread node id is the first column on the header line, comment databaseId is the parenthesized number after each comment body. Use the right one for the operation.

## Scripts

| Script | What it does |
|---|---|
| [scripts/post_inline_comment.sh](scripts/post_inline_comment.sh) | Fetches the PR's current head SHA, posts a `pulls/{n}/comments` REST request with `body` + `commit_id` + `path` + `line` + `side`. Supports `--old` (LEFT side / base version) and `--start-line` (multi-line comments). |
| [scripts/list_comments.sh](scripts/list_comments.sh) | GraphQL query that returns every review thread with its `isResolved` state and comments. `--unresolved` filters to only open threads. Output includes thread node id (for resolve) and per-comment databaseId (for reply). |
| [scripts/resolve_thread.sh](scripts/resolve_thread.sh) | GraphQL `resolveReviewThread` mutation against a thread node id. |
| [scripts/reply_to_comment.sh](scripts/reply_to_comment.sh) | REST `pulls/{n}/comments/{database_id}/replies` — creates a threaded reply to any comment in the thread. |

## Common workflows

### 1. Post a line-anchored review comment

```bash
scripts/post_inline_comment.sh <repo> <pr_number> <path> <line> <body>
```

Example:

```bash
scripts/post_inline_comment.sh \
  anthropic/example 42 \
  'src/foo.ts' 120 \
  'Consider extracting this into its own function — it is reused twice below.'
```

- `--old` to comment on a removed line (LEFT/base side instead of RIGHT/head).
- `--start-line N` to make it a multi-line comment from `N` to `<line>`.

### 2. Triage open review threads

```bash
scripts/list_comments.sh --unresolved <repo> <pr_number>
```

Returns each open thread with its node id, file:line, and all comments in the thread with author + first body line + databaseId.

### 3. Resolve after addressing feedback

```bash
scripts/resolve_thread.sh <thread_node_id>
```

Use the thread node id (first column from `list_comments.sh` header line), NOT a comment databaseId.

### 4. Reply to a reviewer's comment

```bash
scripts/reply_to_comment.sh <repo> <pr_number> <comment_database_id> 'Fair point, I updated it.'
```

Use a comment databaseId (the parenthesized number from `list_comments.sh` output), NOT a thread node id.

**Only reply when the user explicitly asks you to.** Don't auto-reply just because there's an open thread.

## Manual API patterns

When the wrapper scripts don't cover an edge case, fall back to `gh api`:

```bash
# Post inline (REST):
HEAD_SHA="$(gh api repos/<repo>/pulls/<n> --jq .head.sha)"
gh api repos/<repo>/pulls/<n>/comments \
  -X POST \
  -F body='Your comment' \
  -F commit_id="$HEAD_SHA" \
  -F path='src/foo.ts' \
  -F line=120 \
  -F side=RIGHT

# List review threads with resolution state (GraphQL):
gh api graphql -f query='
  query($owner: String!, $name: String!, $number: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id isResolved
            comments(first: 50) {
              nodes { databaseId body path line author { login } }
            }
          }
        }
      }
    }
  }' -F owner=<owner> -F name=<repo> -F number=<n>

# Resolve thread (GraphQL mutation):
gh api graphql -f query='
  mutation($id: ID!) {
    resolveReviewThread(input: {threadId: $id}) {
      thread { id isResolved }
    }
  }' -F id='<thread_node_id>'

# Reply to a comment (REST):
gh api repos/<repo>/pulls/<n>/comments/<comment_database_id>/replies \
  -X POST -F body='Reply text'
```

## Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| Inline comment posts but doesn't anchor to the line | The line is no longer in the current diff (PR was force-pushed or rebased). The script always uses the latest head SHA, but if the line moved or was removed, GitHub may attach as a general comment. Re-fetch the diff and retry. |
| `resolve_thread.sh` fails with "Could not resolve to a node" | You passed a comment databaseId or a thread databaseId instead of the GraphQL node id. Use the first column from `list_comments.sh` (looks like `PRRT_...`). |
| `reply_to_comment.sh` 404s | You passed a thread node id instead of a comment databaseId. Use the parenthesized number from `list_comments.sh`. |
| Permission denied | `gh auth status` to confirm authentication. The token needs `repo` scope for private repos. |
| Multi-line comment shows up as single-line | `--start-line` must be less than `<line>`, both on the same side (handled automatically by the script). |
| "Validation failed: Side cannot be blank" | `gh` quirk — re-run; the script always sends `side` so this should not happen unless gh changes behavior. |
