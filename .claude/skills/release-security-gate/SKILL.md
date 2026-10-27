---
name: release-security-gate
description: Full security pass over the gameWE web content before release-relevant commits are pushed to main (semantic-release then bumps, tags and releases the template and map archives). Use whenever a release is being prepared; ends with a go/no-go report and never tags or pushes on its own.
---

# Release security gate (gameWE web content)

Always run this gate before a release or tag, without asking first.

Run all steps over the whole repository, not only the last diff. Report a
table with the 20 points (ok / finding / n.a.) and a go/no-go.

Releases are made by semantic-release in CI: every push to `main` that
contains a `feat`, `fix` or breaking-change commit (Conventional Commits)
bumps the version, writes `CHANGELOG.md`, tags `vX.Y.Z` and publishes the
GitHub release; the publish job adds one `.tar.gz` per template and
`SHA256SUMS`. So this gate runs **before pushing release-relevant commits to
`main`**, without asking first. Never tag by hand, never edit `VERSION` or
`CHANGELOG.md` by hand, and do not push to `main` yourself: report the gate
result and the version semantic-release will make (`feat` → minor, `fix` →
patch, `!`/`BREAKING CHANGE` → major; the very first release is `1.0.0`),
then ask Dennis for the go.

## Steps

1. **Clean tree and version:** `git status` is clean; the branch is `main`;
   `VERSION` and the top `CHANGELOG.md` entry agree with the latest tag
   (`git describe --tags --abbrev=0`), or none of them exist yet before the
   first release. Every commit since the last tag is signed
   (`git log --format='%h %G? %s' <last tag>..HEAD`, `G` or `U`; the
   `chore(release)` commits of github-actions are the exception).
2. **Checks and packages:** `make clean check package verify`; one archive
   per folder in `templates/` and one per folder in `maps/`; each archive
   lists exactly `<name>/` (or `<game>/`) and its
   files (`tar -tzvf`, owner `0/0`, no links, no absolute paths, no `..`);
   `make package` twice gives the same `dist/SHA256SUMS` (reproducible).
3. **Secrets in the whole history:** prefer
   `gitleaks detect --source . --log-opts="--all"`; otherwise
   `git log -p --all | grep -nEi '(password|secret|token|api[_-]?key|BEGIN [A-Z ]*PRIVATE KEY)'`.
4. **Map pictures:** `make check` passes; no PNG has chunks other than
   `IHDR`, `IDAT`, `IEND` (and colour chunks such as `PLTE`, `tRNS`,
   `gAMA`, `sRGB`), so no text, EXIF or paths; every JSON holds only
   `pos_x`, `pos_y`, `scale` and `source`; the license note on the
   community maps in `README.md` is there.
5. **Template content:** `make check` passes, and by reading: every rule in
   every `theme.css` is scoped to `html[data-skin]`; no `url(`, `@import`,
   addresses, `expression(`, `javascript:`; `chart.json` and
   `template.json` hold only colours and names.
6. **Files in the repo:** `git ls-files` contains only the expected files
   (templates, maps, generator, tools, docs, workflow, skills, root files); no
   `dist/`, archives, `.env`, editor or OS files.
7. **Scripts:** `tools/*.sh` use `set -euo pipefail`, quote every variable,
   take no input except the version (checked against `^[0-9A-Za-z.+-]+$`)
   and write only under `dist/`. Run `shellcheck tools/*.sh` if available.
8. **Workflow:** `.github/workflows/build.yml` builds `main` and pull
   requests, publishes only via semantic-release (no tag trigger, no
   `pull_request_target`), top-level `permissions: contents: read`,
   `contents: write` only for release and publish, pinned action and npm
   package versions, no secrets other than `GITHUB_TOKEN`, no untrusted
   `${{ github.event.* }}` text inside `run:`. Run `actionlint` if
   available.
9. **Install test:** extract one classic, one game and one modern archive
   into an empty folder and run `sha256sum --check --ignore-missing
   SHA256SUMS` from the downloaded location, and the maps archive into an
   empty overviews folder; if a gameWE-web is available,
   mount or point it at those folders and check that the templates are
   listed (visual checks only on Dennis' request, see `CLAUDE.md`).
10. **The 20 points:** go through the `security-check` skill's list for the
   whole repository, with extra attention on changes since the last tag.
11. **Security and privacy audit:** run the `security-privacy-audit`
   skill over the whole repository, all branches and tags since the last
   release, the release commit messages and the `CHANGELOG.md` entry that
   semantic-release will write. Any `BLOCKED` item is a no-go.
12. **Report:** go/no-go, the `security-privacy-audit` summary, findings with
    file:line and fix, the version semantic-release will make and the asset
    list of the release, then ask Dennis for the go to push to `main`.
