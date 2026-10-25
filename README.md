# gameWE web - removed design templates

The design templates (skins) that gameWE-web shipped up to **v0.12.5**
(commit 7509a86) and that were removed afterwards, when only `dark`,
`light`, `orange`, `modern-dark`, `modern-light` and `modern-orange` were
kept. The files are unchanged copies from `templates/` of gameWE-web v0.12.5,
under the same relative path (`templates/<skin>/theme.css`, `chart.json`,
`template.json`). The skins have no images, fonts or translation strings of
their own: the display name is in `template.json`.

| Folder | Kind | gameWE-web now falls back to |
| --- | --- | --- |
| `templates/blue`, `green`, `pink`, `red` | classic colour variants (dark) | `dark` |
| `templates/game-csgo`, `game-css`, `game-cstrike`, `game-dods`, `game-hl2mp` | game designs (dark) | `dark` |
| `templates/game-tf` | game design (light) | `light` |
| `templates/modern-blue`, `modern-gold`, `modern-green`, `modern-pink`, `modern-red` | modern family, generated | `modern-dark` |

`generator/modern-variants.mjs.txt` holds the `VARIANTS` lines of these five
modern skins from `scripts/modern-templates.mjs` (v0.12.5).

## Re-installing a skin

Recommended, survives updates: copy the folder into the own-templates
folder of the installation and point `TEMPLATES_DIR` there, e.g.

```sh
sudo mkdir -p /etc/gamewe/web/templates
sudo cp -r templates/blue /etc/gamewe/web/templates/
# web.env: TEMPLATES_DIR=/etc/gamewe/web/templates  (Docker: mount it, e.g.
#   -v /etc/gamewe/web/templates:/app/custom-templates:ro, TEMPLATES_DIR=/app/custom-templates)
```

Nothing has to be registered: the site lists every folder it finds (Admin >
Settings > Design & logo > "Design (template)") within a minute, and a
folder named like a removed skin is used as it is instead of the fallback.
Game designs (`game-*`) are used on a game's pages when the setting "Game
designs" is on.

Back into the gameWE-web repository itself (built-in again):

1. Copy `templates/<skin>` to `templates/` of gameWE-web.
2. Remove its entry from `REMOVED_TEMPLATES` in `src/lib/skin-fallback.ts`
   and update `tests/skin-fallback.test.ts` (it expects exactly six built-in
   templates) and `templates/README.md`.
3. For a `modern-*` skin also add its line from
   `generator/modern-variants.mjs.txt` to `VARIANTS` in
   `scripts/modern-templates.mjs` and run `npm run templates`: the layout
   rules have changed since v0.12.5, so the generated `theme.css` replaces
   the copied one (`npm test` checks this). Also update
   `tests/modern-templates.test.ts`.

The modern copies here carry the v0.12.5 layout rules; used from
`TEMPLATES_DIR` they keep that older layout until regenerated as above.
