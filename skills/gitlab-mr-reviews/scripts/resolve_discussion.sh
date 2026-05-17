#!/usr/bin/env bash
#
# Mark a GitLab MR discussion as resolved.
#
# Usage:
#   resolve_discussion.sh <project_ref> <mr_iid> <discussion_id>
#
# Example:
#   resolve_discussion.sh coopedu-system/coopedu-admin 433 abc123def456...

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <project_ref> <mr_iid> <discussion_id>" >&2
  exit 1
fi

project_ref="$1"
mr_iid="$2"
discussion_id="$3"

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

glab api \
  "projects/${encoded_project}/merge_requests/${mr_iid}/discussions/${discussion_id}?resolved=true" \
  -X PUT >/dev/null

echo "✅ Resolved discussion ${discussion_id} on MR !${mr_iid}"
