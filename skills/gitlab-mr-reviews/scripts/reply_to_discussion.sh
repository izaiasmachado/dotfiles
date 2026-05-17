#!/usr/bin/env bash
#
# Reply to an existing GitLab MR discussion (adds a note to the thread).
#
# Usage:
#   reply_to_discussion.sh <project_ref> <mr_iid> <discussion_id> <body>
#
# Example:
#   reply_to_discussion.sh coopedu-system/coopedu-admin 433 abc123 \
#     'Boa observação, vou ajustar.'

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <project_ref> <mr_iid> <discussion_id> <body>" >&2
  exit 1
fi

project_ref="$1"
mr_iid="$2"
discussion_id="$3"
body="$4"

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
  "projects/${encoded_project}/merge_requests/${mr_iid}/discussions/${discussion_id}/notes" \
  -X POST \
  --form "body=${body}" >/dev/null

echo "✅ Replied to discussion ${discussion_id} on MR !${mr_iid}"
