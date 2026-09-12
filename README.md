# .github

**Bell State AI Limited, NI743317.**  Organisation wide defaults.

GitHub reads this repository for files that apply across the organisation.  Any
repository without its own copy of one of these gets the version here, so the
rules are written once rather than copied.

    .github/CONTRIBUTING.md          house style, documentation, secrets, tickets, pull requests
    .github/pull_request_template.md what changed, why, and the evidence
    .github/ISSUE_TEMPLATE/          bug report and task forms
    rules/check-write.sh             the machine readable half of CONTRIBUTING.md

A repository may override any of it by adding its own file, and should say why.

**This repository is public because it has to be.**  GitHub only applies these
defaults from a public `.github` repository, though it applies them to private
repositories perfectly well.  Nothing here names a private repository or
describes anything that isn't already public, and it should stay that way.

Workflows and licences are not inherited.  Those live in each repository.

## The rules, enforced

`rules/check-write.sh` is the part of CONTRIBUTING.md a machine can check.  Each
repository carries a short hook that finds this checkout and pipes writes
through it, so the rules live here and a change reaches everybody at their next
pull.

Clone this repository beside the others.  Without it the hook says so once and
gets out of the way, because a missing rulebook is a reason to fetch it and not
a reason to stop working.
