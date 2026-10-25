# Development

## Layout

```
templates/<name>/theme.css       required: CSS variables (modern-*: also layout rules)
templates/<name>/chart.json      chart colours
templates/<name>/template.json   display name (de, en)
generator/modern-variants.mjs.txt  the VARIANTS lines of the modern-* templates
                                 from scripts/modern-templates.mjs of gameWE-web v0.12.5
tools/check-templates.sh         checks every template
tools/package.sh                 builds the release archives and SHA256SUMS
```

How templates work and all variables: `templates/README.md` of
[gameWE-web](https://github.com/DennisPohlmann/gameWE-web/blob/main/templates/README.md).

## Checks

`make check` runs `tools/check-templates.sh`. It fails when

- a folder name is not 1-32 of `a-z`, `0-9`, `-`, `_`,
- `templates/` contains a symbolic link or other special file, or a file
  other than `theme.css`, `chart.json`, `template.json`,
- `theme.css` is missing, larger than 256 KB, has no `html[data-skin]` block,
  or contains `url(`, `@import`, an address or script-like CSS
  (`expression(`, `javascript:`, `behavior:`, `-moz-binding`, `</style>`): a template
  never loads anything from elsewhere,
- `chart.json` is larger than 16 KB or not a JSON object,
- `template.json` is not a JSON object with `name.de` and `name.en`.

Needs `bash`, `find`, `grep` and `jq`.

## Packaging

`make package` (after `make check`) writes, for every template,
`dist/gamewe-web-template-<name>-<version>.tar.gz` with the single folder
`<name>/`, and `dist/SHA256SUMS` over all archives. `make verify` checks
`dist/` against it. The version comes from `VERSION=` on the command line,
else the file `VERSION`, else the latest tag, else `dev`.

The archives are reproducible: entries sorted by name, owner and group 0,
modes `0644`/`0755`, all times set to the time of the last commit, gzip
without name and time. Packing the same commit with the same version always
gives the same `SHA256SUMS`, so anyone can rebuild a release and compare:

```bash
git checkout v1.0.0
make package VERSION=1.0.0
diff dist/SHA256SUMS ~/Downloads/SHA256SUMS
```

(Needs GNU tar 1.28 or newer for `--sort=name`.)

## CI and releases

`.github/workflows/build.yml`:

- **build** (every push to `main`, pull requests, manual runs): `make check`,
  `make package`, `make verify`; the archives are kept as a workflow
  artifact.
- **release** (push to `main` only): semantic-release (`.releaserc.json`)
  reads the Conventional Commits since the last tag. A `feat` gives a minor,
  a `fix` or `perf` a patch, `!`/`BREAKING CHANGE` a major release; other
  types give none. It writes `VERSION` and `CHANGELOG.md`, commits
  `chore(release): vX.Y.Z [skip ci]`, tags `vX.Y.Z` and creates the GitHub
  release.
- **publish** (when a release was made): checks out the tag, packs it with
  that version and uploads every `.tar.gz` and `SHA256SUMS` to the release.

Never tag by hand and never edit `VERSION` or `CHANGELOG.md`. Before
release-relevant commits are pushed to `main`, the `release-security-gate`
skill runs (see `CLAUDE.md`).

Typical commit types here: `feat: add the template <name>` (new template),
`fix(<name>): ...` (colour or contrast fix of a template), `docs: ...`,
`ci: ...`, `chore: ...`. Removing a template is a breaking change
(`feat!: remove the template <name>` with a `BREAKING CHANGE:` footer).
