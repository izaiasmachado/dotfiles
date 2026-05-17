#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  post_inline_comment.sh [--old] [--no-publish] <project_ref> <mr_iid> <path> <line> <comment>

Examples:
  post_inline_comment.sh coopedu-system/coopedu-admin 433 \
    'src/app/sistema/folhas/[id]/processamento/page.tsx' 784 \
    'Padronizar para autenticação em duas etapas.'

  post_inline_comment.sh --old 123 591 \
    'CoopeduApi.Application/Services/TwoFactorTotpService.cs' 119 \
    'Este trecho tem race condition.'
EOF
}

publish=true
line_side="new"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --old)
      line_side="old"
      shift
      ;;
    --no-publish)
      publish=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 5 ]]; then
  usage >&2
  exit 1
fi

project_ref="$1"
mr_iid="$2"
file_path="$3"
line_number="$4"
comment="$5"

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

mr_json="$(glab api "projects/${encoded_project}/merge_requests/${mr_iid}")"

read_sha() {
  local key="$1"
  python3 - <<'PY' "$mr_json" "$key"
import json, sys
payload = json.loads(sys.argv[1])
key = sys.argv[2]
print(payload["diff_refs"][key])
PY
}

base_sha="$(read_sha base_sha)"
start_sha="$(read_sha start_sha)"
head_sha="$(read_sha head_sha)"

declare -a api_args=(
  "projects/${encoded_project}/merge_requests/${mr_iid}/draft_notes"
  -X POST
  --form "note=${comment}"
  --form "position[position_type]=text"
  --form "position[base_sha]=${base_sha}"
  --form "position[start_sha]=${start_sha}"
  --form "position[head_sha]=${head_sha}"
)

if [[ "$line_side" == "old" ]]; then
  api_args+=(--form "position[old_path]=${file_path}")
  api_args+=(--form "position[old_line]=${line_number}")
else
  api_args+=(--form "position[new_path]=${file_path}")
  api_args+=(--form "position[new_line]=${line_number}")
fi

glab api "${api_args[@]}"

if [[ "$publish" == "true" ]]; then
  glab api "projects/${encoded_project}/merge_requests/${mr_iid}/draft_notes/bulk_publish" -X POST >/dev/null
fi
