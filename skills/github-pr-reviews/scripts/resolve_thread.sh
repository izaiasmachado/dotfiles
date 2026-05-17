#!/usr/bin/env bash
#
# Mark a GitHub PR review thread as resolved.
#
# Usage:
#   resolve_thread.sh <thread_id>
#
# <thread_id> is the GraphQL node ID for the review thread (NOT a comment id and
# NOT a database id). Get it from `list_comments.sh` — it's the first column.
#
# Example:
#   resolve_thread.sh PRRT_kwDOABCxyz...
#
# This is GraphQL-only: the REST API does not expose a way to resolve threads.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <thread_id>" >&2
  echo "Get <thread_id> (GraphQL node ID) from list_comments.sh — first column." >&2
  exit 1
fi

thread_id="$1"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 1
fi

mutation='
mutation($id: ID!) {
  resolveReviewThread(input: {threadId: $id}) {
    thread { id isResolved }
  }
}
'

result="$(gh api graphql -f query="$mutation" -F id="$thread_id")"

resolved="$(printf '%s' "$result" | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['resolveReviewThread']['thread']['isResolved'])")"

if [[ "$resolved" == "True" ]]; then
  echo "✅ Resolved thread ${thread_id}"
else
  echo "⚠️  Mutation ran but thread isResolved=${resolved}. Raw response:" >&2
  echo "$result" >&2
  exit 1
fi
