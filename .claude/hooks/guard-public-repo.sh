#!/usr/bin/env bash
# Refuse to write anything into this organisation's public defaults repository
# that would expose a private repository, a secret, or a path from a machine.
#
# Reads a PreToolUse payload on stdin.  Silent and exit 0 for every write that
# is not into that repository, so it costs nothing anywhere else.
#
# The repository is identified by its git remote, not by a path, so this works
# wherever anybody has cloned it.
#
# Nothing here names a private repository.  The rule is that any repository in
# the organisation other than this one is private until proven otherwise, which
# also covers repositories that do not exist yet.
set -uo pipefail

ORG=bellstateai
PUBLIC_REPO=".github"

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

# This script necessarily contains the patterns it searches for, so it would
# otherwise refuse every edit to itself.  It is the only exemption.
case "$file" in
  */.claude/hooks/guard-public-repo.sh) exit 0 ;;
esac

# Walk up to a directory that exists, so a new file in a new folder resolves.
dir=$(dirname "$file")
while [ ! -d "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "." ]; do dir=$(dirname "$dir"); done
origin=$(git -C "$dir" remote get-url origin 2>/dev/null) || exit 0
case "$origin" in
  *"$ORG/$PUBLIC_REPO"*) ;;
  *) exit 0 ;;
esac

body=$(printf '%s' "$payload" | jq -r '
  [.tool_input.content, .tool_input.new_string] | map(select(. != null)) | join("\n")' 2>/dev/null)
[ -n "$body" ] || exit 0

hits=""
flag() { hits="${hits}  - $1"$'\n'; }

# Any repository in the organisation except this one.  No list to leak, and no
# list to keep up to date.
if grep -oE "$ORG/[A-Za-z0-9._-]+" <<<"$body" | grep -qvxF "$ORG/$PUBLIC_REPO"; then
  flag "names another repository in the organisation, which is private"
fi

grep -qE '(/home/|/Users/|C:\\Users\\)' <<<"$body" \
  && flag "carries a path from somebody's machine"
grep -qE '(^|[^0-9a-f])[0-9a-f]{32}([^0-9a-f]|$)' <<<"$body" \
  && flag "carries a 32 character hex string, the shape of an account id or a key"
grep -qiE '(api[_-]?token|client[_-]?secret|secret[_-]?key|access[_-]?key|refresh[_-]?token|password)[[:space:]]*[=:][[:space:]]*[^[:space:]<{"'"'"']{8,}' <<<"$body" \
  && flag "looks like it carries a secret value rather than naming a variable"
grep -qE 'Bearer [A-Za-z0-9._-]{20,}' <<<"$body" \
  && flag "carries a bearer token"
grep -qE '\bbellstate-[a-z0-9-]+\.[a-z0-9.-]+' <<<"$body" \
  && flag "names an internal hostname"

[ -n "$hits" ] || exit 0

jq -n --arg f "$file" --arg h "$hits" --arg o "$ORG/$PUBLIC_REPO" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: (
      $o + " is a public repository.  Refusing to write " + $f + " because it:\n" + $h +
      "\nUse a placeholder such as https://github.com/<org>/<repo>, or put the detail in a private repository instead."
    )
  }
}'
exit 0
