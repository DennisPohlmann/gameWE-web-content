# gameWE - web templates

gameWE is a statistics system for Source and GoldSrc game servers, in the
style of gameME / HLstatsX. This repository holds **optional skins for the gameWE web frontend
([gameWE-web](https://github.com/DennisPohlmann/gameWE-web))**. gameWE-web
itself ships only `dark`, `light`, `orange`, `modern-dark`, `modern-light`
and `modern-orange` (since v0.12.6); every other template lives here, among
them the ones gameWE-web shipped up to v0.12.5. Every release offers each
template as its own `.tar.gz`, ready to unpack into `TEMPLATES_DIR`, plus a
`SHA256SUMS` file to verify them.

A template is a folder with `theme.css` (the CSS variables, for the
`modern-*` family also the layout rules), `chart.json` (chart colours) and
`template.json` (display name). There are no images, fonts, scripts or
translation strings in a template.

Current version: see `VERSION` and [CHANGELOG.md](CHANGELOG.md).

## Templates

| Template | Kind | gameWE-web uses instead while it is not installed |
| --- | --- | --- |
| `blue`, `green`, `pink`, `red` | classic colour variants (dark) | `dark` |
| `game-csgo`, `game-css`, `game-cstrike`, `game-dods`, `game-hl2mp` | game designs (dark) | `dark` |
| `game-tf` | game design (light) | `light` |
| `modern-blue`, `modern-gold`, `modern-green`, `modern-pink`, `modern-red` | modern family (layout and colours) | `modern-dark` |

Game designs (`game-*`) are used on the pages of a game's rankings when the
setting "Game designs" is on (Admin > Settings); every template can also be
chosen as the main design.

## Requirements

- gameWE-web 0.12.6 or newer (older versions still contain these templates)
- `TEMPLATES_DIR` set in gameWE-web, e.g. `/etc/gamewe/web/templates`

## Quick start

Install one template, here `blue` from release `1.0.0`:

```bash
VERSION=1.0.0
NAME=blue
BASE=https://github.com/DennisPohlmann/gameWE-web-templates/releases/download/v$VERSION

curl -fLO "$BASE/gamewe-web-template-$NAME-$VERSION.tar.gz"
curl -fLO "$BASE/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS   # must print ": OK"

sudo mkdir -p /etc/gamewe/web/templates
sudo tar -xzf "gamewe-web-template-$NAME-$VERSION.tar.gz" -C /etc/gamewe/web/templates
```

Each archive contains exactly one folder, `<name>/`, so it lands as
`/etc/gamewe/web/templates/blue/`. Then point gameWE-web at that folder once,
in `web.env`:

```
TEMPLATES_DIR=/etc/gamewe/web/templates
```

and restart it (Docker: mount the folder, e.g.
`-v /etc/gamewe/web/templates:/app/custom-templates:ro`, and set
`TEMPLATES_DIR=/app/custom-templates`). Nothing has to be registered: the
site lists every folder it finds under Admin > Settings > Design & logo >
"Design (template)" within a minute. A folder named like one of the removed
templates is used as it is instead of the fallback above.

Updates of gameWE-web do not touch `TEMPLATES_DIR`. Details, all templates at
once, other platforms and removal: [docs/INSTALLATION.md](docs/INSTALLATION.md).

## Verifying the downloads

Every release has a `SHA256SUMS` file with one line per archive. Download it
from the same release as the archives and check:

```bash
sha256sum --check --ignore-missing SHA256SUMS    # Linux
shasum -a 256 --check --ignore-missing SHA256SUMS   # macOS
```

Every downloaded archive must show `OK`; anything else (`FAILED`, no line)
means the file is damaged or not the released one: do not install it. On
Windows compare `Get-FileHash .\gamewe-web-template-blue-1.0.0.tar.gz` (PowerShell,
SHA256 by default) with the line in `SHA256SUMS`.

The archives are built reproducibly by the release workflow from the tagged
commit, so `make package VERSION=<version>` on a checkout of `v<version>`
gives the same checksums (see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)).

## Documentation

| File | Content |
| --- | --- |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | install one or all templates, Docker, update, removal, putting a template back into gameWE-web |
| [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) | layout, checks, packaging, CI and releases |
| [CHANGELOG.md](CHANGELOG.md) | changes per version |
| [gameWE-web templates/README.md](https://github.com/DennisPohlmann/gameWE-web/blob/main/templates/README.md) | how templates work, all variables, `chart.json`, your own template |

## gameWE components

| Repository | Part |
| --- | --- |
| [gameWE-collector](https://github.com/DennisPohlmann/gameWE-collector) | receives the game server logs and fills the database |
| [gameWE-web](https://github.com/DennisPohlmann/gameWE-web) | statistics website and admin area |
| [gameWE-web-templates](https://github.com/DennisPohlmann/gameWE-web-templates) | extra design templates for the website (this repository) |
| [gameWE-plugin-sourcemod](https://github.com/DennisPohlmann/gameWE-plugin-sourcemod) | game server plugin for Source games |
| [gameWE-plugin-amxmodx](https://github.com/DennisPohlmann/gameWE-plugin-amxmodx) | game server plugin for GoldSrc games |

## Building

```bash
make check     # check every template
make package   # dist/gamewe-web-template-<name>-<version>.tar.gz and dist/SHA256SUMS
make verify    # check dist/ against dist/SHA256SUMS
```

## License

gameWE is free software under the **GNU General Public License version 3 or
later**, see [LICENSE](LICENSE). The templates taken over from gameWE-web
are copies of v0.12.5 (commit 7509a86); the `modern-*` ones are regenerated
with the layout of newer gameWE-web releases, which are under the same
license.
