#!/usr/bin/env bash
#
# Post a line-anchored review comment on a GitHub PR via `gh api`.
#
# Usage:
#   post_inline_comment.sh [--old] [--start-line N] <repo> <pr_number> <path> <line> <body>
#
# Examples:
#   post_inline_comment.sh anthropic/example 42 src/foo.ts 120 'Consider extracting this.'
#   post_inline_comment.sh --old anthropic/example 42 src/foo.ts 80 'This removed branch was actually needed.'
#   post_inline_comment.sh --start-line 100 anthropic/example 42 src/foo.ts 120 'Multi-line note.'
#
# Notes:
# - <repo> is owner/repo (e.g. anthropic/example).
# - The script fetches the PR's head SHA and uses it as commit_id, so the comment
#   anchors to the latest commit on the PR.
# - --old comments on the LEFT (base) side; default is RIGHT (head) side.
# - --start-line creates a multi-line comment from start_line to line.

set -euo pipefail

side="RIGHT"
start_line=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --old)         side="LEFT"; shift ;;
    --start-line)  start_line="$2"; shift 2 ;;
    -h|--help)     sed -n '3,17p' "$0"; exit 0 ;;
    *)             break ;;
  esac
done

if [[ $# -ne 5 ]]; then
  echo "Usage: $0 [--old] [--start-line N] <repo> <pr_number> <path> <line> <body>" >&2
  exit 1
fi

repo="$1"
pr_number="$2"
file_path="$3"
line_number="$4"
body="$5"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is required" >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

# Resolve PR head SHA. GitHub anchors inline comments to a specific commit.
commit_id="$(gh api "repos/${repo}/pulls/${pr_number}" --jq '.head.sha')"

args=(
  "repos/${repo}/pulls/${pr_number}/comments"
  -X POST
  -F "body=${body}"
  -F "commit_id=${commit_id}"
  -F "path=${file_path}"
  -F "line=${line_number}"
  -F "side=${side}"
)

if [[ -n "$start_line" ]]; then
  args+=(-F "start_line=${start_line}" -F "start_side=${side}")
fi

gh api "${args[@]}" >/dev/null

echo "✅ Posted inline comment on ${repo}#${pr_number} at ${file_path}:${line_number} (commit ${commit_id:0:7}, side=${side})"
