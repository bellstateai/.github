# Contributing

**Bell State AI Limited, NI743317.**  These rules apply to every repository in
the organisation.  A repository may add its own `CONTRIBUTING.md` to override
them, and should say why.

## House style

Two spaces after a full stop.  No em dash, no en dash, no curly quotes, no
ellipsis character, no emoji.  British English.

This applies to comments, commit messages and ticket bodies as well as to prose.
Some repositories enforce parts of it with a gate.

## Documentation

**A README is a README.**  What the thing is, what it does, how to set it up,
how to work on it.  Nothing else.

It does not carry a decision log.  No dated entries, no "checked on", no "still
to do", no account of what was chosen over what.  That belongs in the commit
message that made the change and in the ticket that asked for it, both of which
keep their own dates and neither of which goes stale on the page a new starter
reads first.

**A fact lives in the repository that owns it.**  Everywhere else links to it.
Two copies of one fact become two different facts, and the day they disagree
nobody can tell which is true.

**Link to other repositories by URL.**

    https://github.com/<org>/<repo>

Not `../<repo>`, which resolves only for somebody who cloned everything into one
parent using those exact directory names.  Not a path from your own machine,
which resolves for nobody.  Relative paths are for files inside the same
repository, where they are correct and preferred.

Name the repository by its URL and the file by its path inside that repository,
so the reference holds however somebody cloned it.

This one is checked.  A relative path that climbs out of a repository and lands
inside another one is refused.  A path that escapes into something which is not
a repository, such as a build output directory, is left alone.

## Secrets

Never in a repository, and that includes examples that look real.  Name the
variable, say where the value comes from, and stop.

An `.example` file carries placeholders and no live value.

Do not trust an ignore rule you have not tested.  Write a decoy at every path a
real secret could land, run `git add -A`, and read what was actually staged.
Note that `git check-ignore -q` exits zero for a negated match too, so it will
tell you a deliberately kept `.example` file is "ignored".  What `git add` takes
is the answer.

## Tickets

Work gets a ticket on its repository's tracker before it gets a branch.

Story sized.  One ticket for an outcome somebody would notice, not one per
commit, and no chores for committing or pushing.

## Pull requests

Branch, then open a pull request.  The default branch is what has been released,
deployed or applied.

Where a change has an effect that the file diff does not show, put the evidence
in the pull request.  Some changes alter something outside the repository, and
there the diff in the files is not the diff in the world.

Say what you verified and how.  "Tests pass" is a claim; the output is evidence.
If something is unfinished or unproven, say so in the pull request rather than
letting a reviewer find out.
