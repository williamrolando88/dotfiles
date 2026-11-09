# dotfiles

Personal dotfiles for William Morales.

Modern developer environment based on **Fish**, **Kitty**, **Starship**, **Fira Code Nerd Font**, **Homebrew (Linuxbrew)**, and **AI Agent configurations**.

## Estructura del repositorio

```text
dotfiles/
├── .old/                  # Configuraciones previas archivadas (Zsh, scripts anteriores)
├── fish/
│   ├── config.fish        # Homebrew, Starship, mise y carga de los grupos de abreviaciones habilitados
│   ├── fish_plugins       # Plugins gestionados con fisher (plugin-git para las abreviaciones de git)
│   └── abbr/              # Grupos de abreviaciones (git-overrides, docker, strata, antigravity)
├── kitty/
│   ├── kitty.conf         # Tema Tokyo Night y FiraCode ligaduras (compartido)
│   ├── macos.conf         # Atajos con cmd, Option como Alt, prefijos de Homebrew
│   └── linux.conf         # Atajos con ctrl, prefijos de Linuxbrew
├── starship/
│   └── starship.toml      # Prompt minimalista con soporte para Git, Bun, Node, Python, etc.
├── git/
│   └── .gitconfig         # Identidad Git y configuración estándar (rebase = true, main)
├── agents/
│   ├── AGENTS.md          # Instrucciones compartidas para Claude Code y Antigravity
│   └── mcp.json           # Servidores MCP globales (Playwright, etc.)
├── Brewfile               # Herramientas CLI opcionales (selección interactiva)
├── install.sh             # Script de instalación idempotente con symlinks
└── README.md
```

## Instalación en un equipo nuevo

1. Clona el repositorio:
   ```bash
   git clone git@github.com:williamrolando88/dotfiles.git ~/repos/dotfiles
   cd ~/repos/dotfiles
   ```

2. Ejecuta el instalador:
   ```bash
   ./install.sh
   ```

El instalador funciona en macOS y Linux, se ejecuta por pasos y cada paso detecta lo que
ya existe antes de preguntar si instalar o cambiar algo:

| Paso     | Qué hace |
|----------|----------|
| `kitty`  | Detecta Kitty (PATH o app ya instalada) o lo instala con `brew install --cask kitty` |
| `fish`   | Detecta Fish o lo instala con `brew install fish` |
| `prompt` | Starship y FiraCode Nerd Font |
| `links`  | Symlinks a `~/.config` y `~/.gitconfig`. Si ya existe un archivo distinto, lo respalda como `<archivo>.bak.<timestamp>` |
| `plugins` | Instala fisher (Homebrew), enlaza `fish/fish_plugins` y sincroniza con `fisher update`. Las abreviaciones de git vienen de `jhillyerd/plugin-git` |
| `abbr`   | Checklist de los grupos de `fish/abbr/`: muestra si el programa está instalado (solo informativo) y enlaza los grupos marcados en `~/.config/fish/abbr.d/`, que `config.fish` carga. Los desmarcados se quitan; un archivo propio en esa carpeta no se toca |
| `agents` | Enlaza `agents/` en `~/.agents`. Antigravity: symlinks en `~/.gemini/config`. Claude Code: agrega `@~/.agents/AGENTS.md` a `~/.claude/CLAUDE.md` y registra los servidores de `mcp.json` con `claude mcp add-json --scope user` |
| `shell`  | Opcional: agrega fish a `/etc/shells` y lo deja como login shell (`chsh`). Kitty abre fish aunque se omita |
| `tools`  | Checklist del Brewfile: cada paquete aparece marcado si está instalado. Al aplicar, instala lo marcado que falta y desinstala lo desmarcado, previa confirmación. Solo afecta paquetes del Brewfile |

Para agregar o quitar herramientas de la lista, edita el `Brewfile`: el comentario `#` sobre
cada línea es la descripción que aparece en la checklist.

Se puede ejecutar un paso suelto, por ejemplo `./install.sh links` o `./install.sh kitty fish`.
Ejecutarlo de nuevo es seguro: lo que ya está instalado o enlazado se omite.

Kitty carga `macos.conf` o `linux.conf` automáticamente mediante `include ${KITTY_OS}.conf`.
