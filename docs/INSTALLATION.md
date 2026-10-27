# Installation

The templates are installed into `/var/lib/gamewe/web/templates`, the map
pictures into `/var/lib/gamewe/web/overviews` (see [Map pictures](#map-pictures)).
gameWE-web reads both in addition to its built-in templates and pictures;
updates of gameWE-web do not touch them.

## 1. Make the folders known to gameWE-web (once)

- **gameWE-web 0.36.0 and newer, package or source installation:**
  nothing to do; it reads these two fixed folders.
- **Docker:** mount the host folders read-only to the same paths in the
  container. The container runs as uid 1000, so the files must be readable
  for it (e.g. `sudo chmod -R o+rX /var/lib/gamewe/web`):

  ```bash
  docker run ... \
    -v /var/lib/gamewe/web/templates:/var/lib/gamewe/web/templates:ro \
    -v /var/lib/gamewe/web/overviews:/var/lib/gamewe/web/overviews:ro \
    ...
  ```

- **gameWE-web before 0.36.0:** set the two folders in `web.env` (e.g.
  `/etc/gamewe/web/web.env`), in Docker as `-e`, and restart gameWE-web:

  ```
  TEMPLATES_DIR=/var/lib/gamewe/web/templates
  OVERVIEWS_DIR=/var/lib/gamewe/web/overviews
  ```

  Newer versions ignore these variables and warn in the log while they are
  set. If you used another folder before (e.g. `/etc/gamewe/web/templates`
  from older versions of this guide), move its contents to the folders above.

Adding or changing templates later needs no restart; the site picks them up
within a minute.

## 2. Install a template

Download the archive and `SHA256SUMS` of the same release from
<https://github.com/DennisPohlmann/gameWE-web-content/releases>, verify and
extract:

```bash
VERSION=1.0.0
NAME=modern-blue
BASE=https://github.com/DennisPohlmann/gameWE-web-content/releases/download/v$VERSION

curl -fLO "$BASE/gamewe-web-template-$NAME-$VERSION.tar.gz"
curl -fLO "$BASE/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS

sudo mkdir -p /var/lib/gamewe/web/templates
sudo tar -xzf "gamewe-web-template-$NAME-$VERSION.tar.gz" -C /var/lib/gamewe/web/templates
```

With the GitHub CLI:

```bash
gh release download "v$VERSION" -R DennisPohlmann/gameWE-web-content \
  -p "gamewe-web-template-$NAME-$VERSION.tar.gz" -p SHA256SUMS
```

All templates at once:

```bash
gh release download "v$VERSION" -R DennisPohlmann/gameWE-web-content
sha256sum --check --strict SHA256SUMS
for f in gamewe-web-template-*-"$VERSION".tar.gz; do
  sudo tar -xzf "$f" -C /var/lib/gamewe/web/templates
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

Delete the folder, e.g. `sudo rm -r /var/lib/gamewe/web/templates/blue`. A site
that still uses it falls back to `dark`, `light` or `modern-dark` (see the
table in [README.md](../README.md#templates)).

## Notes on the modern templates

The `modern-*` templates carry the layout rules of gameWE-web v0.29.0 (the
same rules as its built-in `modern-dark`, `modern-light` and
`modern-orange`). Used from `/var/lib/gamewe/web/templates` they keep that layout; a newer
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

## Map pictures

One archive per game, `gamewe-web-maps-<game>-<version>.tar.gz`, holds the
single folder `<game>/` with `<map>.png` and `<map>.json` per map.

1. Make the folder known to gameWE-web as in
   [step 1](#1-make-the-folders-known-to-gamewe-web-once) above (Docker
   mount, or `OVERVIEWS_DIR` before 0.36.0).

2. Download, verify and extract:

   ```bash
   VERSION=1.2.0
   GAME=css
   gh release download "v$VERSION" -R DennisPohlmann/gameWE-web-content \
     -p "gamewe-web-maps-$GAME-$VERSION.tar.gz" -p SHA256SUMS
   sha256sum --check --ignore-missing SHA256SUMS

   sudo mkdir -p /var/lib/gamewe/web/overviews
   sudo tar -xzf "gamewe-web-maps-$GAME-$VERSION.tar.gz" -C /var/lib/gamewe/web/overviews
   ```

The map page looks for a picture in the folder of the ranking's game code
first, then in the folder of its base game (`css` for every CS:S-based game
code), then directly in `/var/lib/gamewe/web/overviews`; picture and
calibration are looked up separately. An installed file wins over a
built-in picture of the same name. Files must be plain files (no symbolic links) with lower-case
names, PNGs at most 8 MB, JSONs at most 64 KB; the archives meet that.

Update: extract the new archive over the old folder. Removal: delete the
folder, e.g. `sudo rm -r /var/lib/gamewe/web/overviews/css`; maps without a
picture show the heatmap on a plain background again.

## Troubleshooting

- **The template is not listed:** check the folder (Docker: the mount,
  `docker inspect`; before 0.36.0: `TEMPLATES_DIR` of the running
  service), that the file is `/var/lib/gamewe/web/templates/<name>/theme.css`
  (not one level deeper) and readable, and wait a minute.
- **A map shows no picture:** check the folder as above, that the files
  are `/var/lib/gamewe/web/overviews/css/<map>.png` and `.json` (not one level deeper) with
  the map's name in lower case, and that they are readable.
- **`sha256sum` prints `FAILED`:** download the archive again; if it still
  fails, do not install it and open an issue.
- **`sha256sum: no file was verified`:** the archive name does not match a
  line in `SHA256SUMS`; take both from the same release.
