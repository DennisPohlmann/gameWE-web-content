# Installation

The templates are installed into the `TEMPLATES_DIR` of gameWE-web, a folder
outside the installation that updates do not touch. The examples use
`/etc/gamewe/web/templates`; any folder the web server can read works.

## 1. Point gameWE-web at the folder (once)

Package or source installation, in `web.env` (e.g. `/etc/gamewe/web/web.env`):

```
TEMPLATES_DIR=/etc/gamewe/web/templates
```

Docker: mount the folder read-only and set the variable:

```bash
docker run ... \
  -v /etc/gamewe/web/templates:/app/custom-templates:ro \
  -e TEMPLATES_DIR=/app/custom-templates \
  ...
```

Restart gameWE-web after changing `TEMPLATES_DIR`. Adding or changing
templates later needs no restart; the site picks them up within a minute.

## 2. Install a template

Download the archive and `SHA256SUMS` of the same release from
<https://github.com/DennisPohlmann/gameWE-web-templates/releases>, verify and
extract:

```bash
VERSION=1.0.0
NAME=modern-blue
BASE=https://github.com/DennisPohlmann/gameWE-web-templates/releases/download/v$VERSION

curl -fLO "$BASE/gamewe-web-template-$NAME-$VERSION.tar.gz"
curl -fLO "$BASE/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS

sudo mkdir -p /etc/gamewe/web/templates
sudo tar -xzf "gamewe-web-template-$NAME-$VERSION.tar.gz" -C /etc/gamewe/web/templates
```

With the GitHub CLI:

```bash
gh release download "v$VERSION" -R DennisPohlmann/gameWE-web-templates \
  -p "gamewe-web-template-$NAME-$VERSION.tar.gz" -p SHA256SUMS
```

All templates at once:

```bash
gh release download "v$VERSION" -R DennisPohlmann/gameWE-web-templates
sha256sum --check --strict SHA256SUMS
for f in gamewe-web-template-*-"$VERSION".tar.gz; do
  sudo tar -xzf "$f" -C /etc/gamewe/web/templates
done
```

Only plain folders and files are used by gameWE-web (no symbolic links);
`tar -xzf` as above keeps them that way. The files only need to be readable
by the user gameWE-web runs as.

## 3. Choose it

Admin > Settings > Design & logo > "Design (template)". Game designs
(`game-*`) are used on a game's pages while "Game designs" is on.

## Update

Download the new release, verify and extract it over the old folder as in
step 2. Changed files replace the old ones; a template keeps its name, so
the setting stays.

## Removal

Delete the folder, e.g. `sudo rm -r /etc/gamewe/web/templates/blue`. A site
that still uses it falls back to `dark`, `light` or `modern-dark` (see the
table in [README.md](../README.md#templates)).

## Notes on the modern templates

The `modern-*` templates carry the layout rules of gameWE-web v0.29.0 (the
same rules as its built-in `modern-dark`, `modern-light` and
`modern-orange`). Used from `TEMPLATES_DIR` they keep that layout; a newer
gameWE-web may change the layout of its own modern templates later. Then
install the newest release of these templates, or put the template back into
gameWE-web as below.

## Putting a template back into gameWE-web (built in again)

1. Copy `templates/<name>` to `templates/` of gameWE-web.
2. Remove its entry from `REMOVED_TEMPLATES` in `src/lib/skin-fallback.ts`
   and update `tests/skin-fallback.test.ts` (it expects exactly six built-in
   templates) and `templates/README.md`.
3. For a `modern-*` template also add its line from
   [`generator/modern-variants.mjs.txt`](../generator/modern-variants.mjs.txt)
   to `VARIANTS` in `scripts/modern-templates.mjs` and run
   `npm run templates`: the generated `theme.css` replaces the copied one
   (`npm test` checks this). Also update `tests/modern-templates.test.ts`.

## Troubleshooting

- **The template is not listed:** check that the running service really
  has `TEMPLATES_DIR` (Docker: `docker inspect`, also the mount), that the folder is `TEMPLATES_DIR/<name>/theme.css` (not one level
  deeper) and readable, and wait a minute.
- **`sha256sum` prints `FAILED`:** download the archive again; if it still
  fails, do not install it and open an issue.
- **`sha256sum: no file was verified`:** the archive name does not match a
  line in `SHA256SUMS`; take both from the same release.
