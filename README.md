# .github

**Bell State AI Limited, NI743317.**  Organisation wide defaults.

GitHub reads this repository for files that apply across the organisation.  Any
repository without its own copy of one of these gets the version here, so the
rules are written once rather than copied.

    .github/CONTRIBUTING.md          house style, documentation, secrets, tickets, pull requests
    .github/pull_request_template.md what changed, why, and the evidence
    .github/ISSUE_TEMPLATE/          bug report and task forms

A repository may override any of it by adding its own file, and should say why.

**This repository is public because it has to be.**  GitHub only applies these
defaults from a public `.github` repository, though it applies them to private
repositories perfectly well.  Nothing here names a private repository or
describes anything that isn't already public, and it should stay that way.

Workflows and licences are not inherited.  Those live in each repository.
