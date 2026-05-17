#!/usr/bin/env bash
#
# Reply to a GitHub PR review comment (threaded reply on the same thread).
#
# Usage:
#   reply_to_comment.sh <repo> <pr_number> <comment_database_id> <body>
#
# Example:
#   reply_to_comment.sh anthropic/example 42 1234567890 'Fair point, let me think about it.'
#
# <comment_database_id> is the integer REST id of any comment in the thread you want
# to reply to. Get it from `list_comments.sh` — the parenthesized number after each
# comment line, e.g. `@alice: Looks good   (1234567890)`.

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <repo> <pr_number> <comment_database_id> <body>" >&2
  echo "Get <comment_database_id> from list_comments.sh — the (number) after each comment." >&2
  exit 1
fi

repo="$1"
pr_number="$2"
comment_id="$3"
body="$4"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 1
fi

gh api \
  "repos/${repo}/pulls/${pr_number}/comments/${comment_id}/replies" \
  -X POST \
  -F "body=${body}" >/dev/null

echo "✅ Replied to comment ${comment_id} on ${repo}#${pr_number}"
