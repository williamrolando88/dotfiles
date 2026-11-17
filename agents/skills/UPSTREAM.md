# Skills de terceros

Copias sin modificar de los `SKILL.md` originales. `./install.sh agents` enlaza cada
carpeta en `~/.agents/skills/` (pi), `~/.claude/skills/` (Claude Code) y
`~/.gemini/skills/` (Antigravity CLI).

| Skills | Origen | Commit | Licencia |
|--------|--------|--------|----------|
| `ponytail`, `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-help`, `ponytail-gain` | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) `skills/` | `96608e0` (2026-10-29) | MIT (`LICENSE.ponytail`) |
| `caveman`, `ultracave` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) `skills/` | `9b24366` (2026-11-16) | Apache-2.0 (`LICENSE.caveman`, `NOTICE.caveman`) |

Solo se copian las skills, no los plugins: sin hooks, sin la band de ponytail y sin el
CLI, proxy ni Caveman Cloud. Por eso ponytail se activa por su descripción (tareas de
código) y caveman solo al pedirlo (`/caveman`, "be brief"; `/caveman ultra` o `/ultracave` para
la versión más comprimida).

Lo que las skills mencionan pero no funciona sin los plugins: `/caveman wenyan` (apunta a
`megacave`, no copiada), y en `/ponytail-help`
la band, `/plugin` y el modo por defecto (`PONYTAIL_DEFAULT_MODE`,
`~/.config/ponytail/config.json`), que solo leen los hooks del plugin.

Para actualizar: clona el repo de origen, revisa el diff de los `SKILL.md`, cópialos
encima y actualiza el commit de esta tabla.
