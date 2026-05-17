#!/usr/bin/env bash
#
# List discussions on a GitLab MR. Optionally filter to only unresolved ones.
#
# Usage:
#   list_discussions.sh [--unresolved] <project_ref> <mr_iid>
#
# Examples:
#   list_discussions.sh coopedu-system/coopedu-admin 433
#   list_discussions.sh --unresolved coopedu-system/coopedu-admin 433
#
# Output (per discussion):
#   <discussion_id>  [resolved=true/false]  <author>  <file>:<line>
#     <first line of body>

set -euo pipefail

unresolved_only=false
if [[ "${1:-}" == "--unresolved" ]]; then
  unresolved_only=true
  shift
fi

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 [--unresolved] <project_ref> <mr_iid>" >&2
  exit 1
fi

project_ref="$1"
mr_iid="$2"

if ! command -v glab >/dev/null 2>&1; then
  echo "glab is required" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

encoded_project="$(python3 - <<'PY' "$project_ref"
import sys
from urllib.parse import quote
print(quote(sys.argv[1], safe=''))
PY
)"

# GitLab paginates discussions; pull everything with per_page=100 and loop until empty.
raw="$(glab api --paginate "projects/${encoded_project}/merge_requests/${mr_iid}/discussions?per_page=100")"

python3 - "$raw" "$unresolved_only" <<'PY'
import json, sys

discussions = json.loads(sys.argv[1])
unresolved_only = sys.argv[2] == "true"

shown = 0
for d in discussions:
    notes = d.get("notes", [])
    if not notes:
        continue
    # A discussion is "resolvable" if its first note is. Resolved state lives on the note.
    head = notes[0]
    if not head.get("resolvable", False):
        continue  # unresolvable (e.g. general comment without diff position) — skip
    is_resolved = head.get("resolved", False)
    if unresolved_only and is_resolved:
        continue

    author = head.get("author", {}).get("username", "?")
    pos = head.get("position") or {}
    file_path = pos.get("new_path") or pos.get("old_path") or "(no diff)"
    line = pos.get("new_line") or pos.get("old_line") or "?"
    first_line = (head.get("body") or "").splitlines()[0] if head.get("body") else ""
    if len(first_line) > 80:
        first_line = first_line[:77] + "..."

    state = "resolved" if is_resolved else "OPEN"
    print(f"{d['id']}  [{state}]  @{author}  {file_path}:{line}")
    print(f"  {first_line}")
    print()
    shown += 1

if shown == 0:
    msg = "No unresolved discussions." if unresolved_only else "No resolvable discussions."
    print(msg, file=sys.stderr)
PY
