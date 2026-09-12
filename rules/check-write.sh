#!/usr/bin/env bash
# The organisation's write rules, in one place.
#
# Every repository's PreToolUse hook is a thin bootstrap that finds this file
# and pipes its payload here, so the rules are written once and a change lands
# everywhere at the next pull.
#
# Reads a PreToolUse payload on stdin.  Prints a deny decision, or nothing.
set -uo pipefail

ORG=bellstateai
PUBLIC_REPO=".github"

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

# This file and the bootstraps contain the patterns they search for, so they
# would otherwise refuse every edit to themselves.
case "$file" in
  */rules/check-write.sh|*/.claude/hooks/org-rules.sh) exit 0 ;;
esac

body=$(printf '%s' "$payload" | jq -r '
  [.tool_input.content, .tool_input.new_string] | map(select(. != null)) | join("\n")' 2>/dev/null)
[ -n "$body" ] || exit 0

# Which repository is being written into?
dir=$(dirname "$file")
while [ ! -d "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "." ]; do dir=$(dirname "$dir"); done
origin=$(git -C "$dir" remote get-url origin 2>/dev/null) || origin=""
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root=""

hits=""
flag() { hits="${hits}  - $1"$'\n'; }

# ---------------------------------------------------------------- every repo
#
# A relative path that climbs out of this repository and lands inside another
# one.  It resolves only for somebody who cloned both into the same parent
# using those exact directory names.
#
# This is decided by resolving the path, not by matching repository names, so
# there is no list here to leak or to keep up to date.  A path that escapes
# into something which is not a repository, such as a build output directory,
# is left alone.
if [ -n "$root" ]; then
  while read -r rel; do
    [ -n "$rel" ] || continue
    target=$(cd "$dir" 2>/dev/null && cd "$(dirname "$rel")" 2>/dev/null && pwd) || continue
    other=$(git -C "$target" rev-parse --show-toplevel 2>/dev/null) || continue
    if [ "$other" != "$root" ]; then
      flag "points at another repository by a relative path ($rel), which resolves only if both were cloned side by side.  Name the repository by its URL and the file by its path inside it"
      break
    fi
  done < <(grep -oE '\.\./[A-Za-z0-9._/-]+' <<<"$body" | sort -u)
fi

# -------------------------------------------------- the public repo, and only it
case "$origin" in
  *"$ORG/$PUBLIC_REPO"*)
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
    ;;
esac

[ -n "$hits" ] || exit 0

jq -n --arg f "$file" --arg h "$hits" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Refusing to write " + $f + " because it:\n" + $h + "\nSee CONTRIBUTING.md in the organisation defaults repository.")
  }
}'
exit 0
