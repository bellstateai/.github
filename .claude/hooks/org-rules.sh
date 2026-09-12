#!/usr/bin/env bash
# Finds the organisation's write rules and applies them.
#
# The rules themselves are not here.  They live in the organisation defaults
# repository, so there is one copy of them and a change lands everywhere at the
# next pull.  This file only locates that checkout.
#
# If it is not checked out, this says so once and allows the write.  A missing
# rulebook is a reason to fetch it, not a reason to stop working.
set -uo pipefail

ORG_DEFAULTS_URL="https://github.com/bellstateai/.github"

payload=$(cat)

here="${CLAUDE_PROJECT_DIR:-$PWD}"
found=""
for d in "$(dirname "$here")"/*/; do
  url=$(git -C "$d" remote get-url origin 2>/dev/null) || continue
  case "$url" in *bellstateai/.github*) found="${d%/}"; break ;; esac
done

if [ -z "$found" ]; then
  # Say it once a session.  A hook that nags on every write gets turned off.
  sid=$(printf '%s' "$payload" | jq -r '.session_id // "nosession"' 2>/dev/null)
  mark="${TMPDIR:-/tmp}/claude-org-rules-notice-${sid}"
  if [ ! -e "$mark" ]; then
    : > "$mark" 2>/dev/null || true
    jq -n --arg u "$ORG_DEFAULTS_URL" '{
      systemMessage: ("The organisation write rules are not checked out, so nothing is being checked against them.  Clone " + $u + " beside this repository to turn the checks on.")
    }'
  fi
  exit 0
fi

rules="$found/rules/check-write.sh"
[ -x "$rules" ] || exit 0
printf '%s' "$payload" | bash "$rules"
