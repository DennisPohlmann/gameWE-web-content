# gameWE web content - notes for Claude

Optional content for gameWE-web that it does not ship itself (the repo was
called gameWE-web-templates up to v1.1.1): design templates (skins),
starting with the ones it removed after v0.12.5, and map pictures with
their calibration for community maps (`maps/<game>/<map>.png` + `.json`,
installed into `/var/lib/gamewe/web/overviews`); more can be added. Never
hard-code the number of templates or maps in docs or scripts. One folder per template under `templates/<name>/`
with `theme.css` (CSS variables; `modern-*` also layout rules), `chart.json`
(chart colours) and `template.json` (display name de/en). No code runs from
this repository on a server: gameWE-web reads the files from
`/var/lib/gamewe/web/templates` (before 0.36.0: `TEMPLATES_DIR`) and only
takes CSS variables, layout rules scoped to `html[data-skin]` and plain
colour values. `generator/modern-variants.json` holds the colours of the `modern-*` templates;
`make modern WEB=<gameWE-web checkout>` regenerates them with gameWE-web's
`scripts/modern-templates.mjs` (`--variants`, `--out`). Map pictures: one folder per game code
under `maps/` (base game, e.g. `css`), in it only `<map>.png` (2048 x 2048,
no metadata, at most 8 MB) and `<map>.json` (`pos_x`, `pos_y`, `scale`, at
most 64 KB), lower-case names; they are community maps of other authors,
so keep the license note in `README.md`.

Build: `make check` (tools/check-templates.sh, tools/check-maps.sh),
`make package` (tools/package.sh: one reproducible
`dist/gamewe-web-template-<name>-<version>.tar.gz` per template, one
`dist/gamewe-web-maps-<game>-<version>.tar.gz` per game folder, each with
its own `dist/<archive>.sha256`), `make verify`.

Releases: Conventional Commits + semantic-release (`.releaserc.json`). The
GitHub workflow checks and packs every push to `main` (workflow artifact
only); `feat`/`fix`/breaking commits make semantic-release bump `VERSION`,
write `CHANGELOG.md`, commit `chore(release): vX.Y.Z [skip ci]`, tag
`vX.Y.Z` and publish the GitHub release; the publish job then adds every
archive and its `.sha256`. There is no tag-triggered workflow.

## Documentation layout (the same in all gameWE repos)

- Root: `README.md` (overview, requirements, quick start, verifying,
  documentation table, components, building, license), `CHANGELOG.md`
  (generated), `LICENSE`, `CLAUDE.md`.
- `docs/`: `INSTALLATION.md` (install, update, uninstall, troubleshooting),
  `DEVELOPMENT.md` (layout, checks, packaging, CI, releases). How templates
  work in general is documented in gameWE-web's `templates/README.md`; link
  to it instead of copying it.
- New documentation goes into the matching file there; no other top-level
  doc files.

## Security is part of every change (mandatory)

1. **Every change:** before you call a change done, commit it or open a PR,
   run the `security-check` skill on the diff and fix what it finds. Say in
   your answer which checklist points the change touched and the result
   (one or two lines are enough when nothing was found).
2. **Every release, without exception (standing rule from Dennis):**
   releases are made by semantic-release in CI when `feat`, `fix` or
   breaking-change commits reach `main`. Before pushing such commits to
   `main`, run the `release-security-gate` skill over the whole repo,
   without asking first. Never tag by hand or edit `VERSION` /
   `CHANGELOG.md`; report the gate result and ask Dennis for the go before
   the push.
3. **Sensitive data, every task (standing rule from Dennis):** before you
   call a task done, commit or publish anything, run the
   `security-privacy-audit` skill over the working tree, the diff, docs and
   the commit message, and end the answer with its audit summary. A
   `BLOCKED` finding stops the commit; report only category and location,
   never the value.
4. A finding you cannot fix in scope goes into the answer with file:line,
   impact and a proposed fix. Never weaken `tools/check-templates.sh` to get
   green.

## Before every commit (mandatory, standing rule from Dennis)

Run the `pre-commit-checklist` skill before every `git commit`, together
with `security-check` and `security-privacy-audit`, also for small fixes.
Commits are signed (`commit.gpgsign` with Dennis' SSH key); never commit
with `--no-gpg-sign`.

## Visual checks

Screenshots or visual tests of templates are made with gameWE-web. Standing
rule from Dennis: web checks are only done in the six built-in skins `dark`,
`white`/`light`, `orange`, `modern-dark`, `modern-white`/`modern-light`,
`modern-orange`, each on desktop and phone. The templates in this repository
are not checked visually unless Dennis asks for a specific one.

## Invariants that must not break

- A template is only `theme.css`, `chart.json`, `template.json`: no other
  files, no symbolic links, no images, fonts or scripts.
- `theme.css` never loads anything: no `url()`, `@import`, addresses or
  script-like CSS; every rule is scoped to `html[data-skin]`.
- Folder names: 1-32 of `a-z`, `0-9`, `-`, `_` (gameWE-web ignores others).
- Limits of gameWE-web: `theme.css` at most 256 KB, `chart.json` at most
  16 KB.
- Each release archive holds exactly one folder `<name>/`; archives stay
  reproducible (`tools/package.sh`) and each has its own `<archive>.sha256`
  (no combined checksum file).
- Removing or renaming a template is a breaking change.
