---
name: security-check
description: Security checklist for every change in the gameWE web content (theme.css, chart.json, template.json, packaging scripts, release workflow). Use before finishing, committing or opening a PR for any change in this repository.
---

# Security check for a change (gameWE web content)

Scope: the current diff (`git diff` plus staged and untracked files). Walk
the points below, only as deep as the diff reaches, and report the result.
This repository holds only data files that gameWE-web loads as styles, plus
two shell scripts and one workflow; many points of the original web-app
list are mapped to what that means here.

## Steps

1. Read the diff: `git status --short`, `git diff HEAD`.
2. List new or changed templates, files in `tools/`, the workflow and
   `.releaserc.json`.
3. For each point below that the diff touches, check it in the files.
4. Run `make clean check package verify`. If `jq` is missing, say so.
5. Quick secret grep on the diff:
   `git diff HEAD | grep -nEi '(password|secret|token|api[_-]?key|PRIVATE KEY)'`.
6. Fix what you find, then report: touched points, findings with
   file:line, what you fixed, what is left.

## The checklist, adapted to the templates

1. **Secrets / keys:** no tokens, keys or passwords in files, scripts,
   workflow or docs; the workflow uses only `GITHUB_TOKEN`.
2. **Least privilege:** the workflow has `contents: read` at the top and
   `contents: write` only in the release and publish jobs.
3. **IDOR:** not applicable.
4. **Git secrets:** see step 5; `dist/`, `*.tar.gz` and `SHA256SUMS` stay
   ignored and are never committed.
5. **Admin routes:** not applicable (the admin area of gameWE-web has its
   own design; a template must not try to style or hide it).
6. **User isolation:** a template shows nothing about players; it cannot
   add content (no `content:` with text that pretends to be site content).
7. **Rate limits:** not applicable.
8. **Storage:** `tools/package.sh` writes only under `dist/`; archives hold
   only `<name>/` with plain files, owner 0:0, modes 0644/0755.
9. **Input validation:** folder names 1-32 of `a-z0-9_-`; only
   `theme.css`, `chart.json`, `template.json`; sizes within the limits of
   gameWE-web (256 KB, 16 KB); JSON is an object. Map pictures: game folder
   `^[a-z0-9][a-z0-9_-]{0,31}$`, only lower-case `<map>.png` (real PNG, at
   most 8 MB, no text or EXIF chunks that could carry paths or names) and
   `<map>.json` (`pos_x`, `pos_y`, `scale`, at most 64 KB), always in
   pairs. `make check` enforces it (the metadata check is by hand).
10. **Unauthenticated entry points:** not applicable (no code runs on a
    server from this repo).
11. **Injection:** CSS injection: every rule scoped to `html[data-skin]`, no
    `url(`, `@import`, addresses, `expression(`, `javascript:`,
    `behavior:`, `-moz-binding`, no `</style>`; chart colours plain values
    only. Shell: every variable quoted, no `eval`, the version validated.
    Workflow: no untrusted `${{ github.event.* }}` text in `run:`.
12. **Sensitive logs:** CI output contains no secrets (`set -x` is not used
    with tokens).
13. **Field tampering:** not applicable.
14. **Uploads:** the release assets are only the archives from
    `make package` and `SHA256SUMS`, built from the tag in CI.
15. **Server logic:** gameWE-web, not the template, decides what is
    shown; a template only changes colours and layout.
16. **Trim responses:** not applicable.
17. **Auth sessions:** not applicable.
18. **Dependencies:** a change to action versions, the runner image, the
    pinned semantic-release packages or the required tools (`jq`, GNU tar)
    gets a note.
19. **Record access:** not applicable.
20. **Attack your own change:** try one hostile input (a symlink in a
    template folder, a `theme.css` with `url(https://...)` or `@import`, a
    folder named `../x` or with upper case, a 300 KB `theme.css`, a broken
    `chart.json`; in `maps/` a symlink, an upper-case name, a text file
    named `.png`, a JSON without `scale`) and check that `make check` stops
    it.
