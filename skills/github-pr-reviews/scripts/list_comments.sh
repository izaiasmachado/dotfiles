#!/usr/bin/env bash
#
# List review threads on a GitHub PR. Optionally filter to only unresolved ones.
#
# Usage:
#   list_comments.sh [--unresolved] <repo> <pr_number>
#
# Examples:
#   list_comments.sh anthropic/example 42
#   list_comments.sh --unresolved anthropic/example 42
#
# Output (per thread):
#   <thread_id>  [resolved=true/false]  <file>:<line>
#     @<author>: <first line of body>   (<comment_db_id>)
#     @<author>: <first line of body>   (<comment_db_id>)
#
# Uses GraphQL because the REST API does NOT expose thread-resolved state.
# thread_id is the GraphQL node ID (use it with resolve_thread.sh).
# comment_db_id is the REST database id (use it with reply_to_comment.sh).

set -euo pipefail

unresolved_only=false
if [[ "${1:-}" == "--unresolved" ]]; then
  unresolved_only=true
  shift
fi

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 [--unresolved] <repo> <pr_number>" >&2
  exit 1
fi

repo="$1"
pr_number="$2"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

owner="${repo%%/*}"
name="${repo##*/}"

query='
query($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 50) {
            nodes {
              databaseId
              body
              path
              line
              originalLine
              author { login }
            }
          }
        }
      }
    }
  }
}
'

raw="$(gh api graphql -f query="$query" -F owner="$owner" -F name="$name" -F number="$pr_number")"

python3 - "$raw" "$unresolved_only" <<'PY'
import json, sys

data = json.loads(sys.argv[1])
unresolved_only = sys.argv[2] == "true"

threads = data["data"]["repository"]["pullRequest"]["reviewThreads"]["nodes"]
shown = 0
for t in threads:
    if unresolved_only and t["isResolved"]:
        continue
    comments = t["comments"]["nodes"]
    if not comments:
        continue

    head = comments[0]
    state = "resolved" if t["isResolved"] else "OPEN"
    file_path = head.get("path") or "(unknown)"
    line = head.get("line") or head.get("originalLine") or "?"
    print(f"{t['id']}  [{state}]  {file_path}:{line}")
    for c in comments:
        author = c.get("author", {}).get("login", "?")
        first_line = (c.get("body") or "").splitlines()[0] if c.get("body") else ""
        if len(first_line) > 80:
            first_line = first_line[:77] + "..."
        print(f"  @{author}: {first_line}   ({c['databaseId']})")
    print()
    shown += 1

if shown == 0:
    msg = "No unresolved threads." if unresolved_only else "No review threads."
    print(msg, file=sys.stderr)
PY
