# dotfiles

Personal dotfiles for William Morales.

Modern developer environment for **macOS and Linux** based on **Fish**, **Kitty**, **Starship**, **FiraCode Nerd Font**, **Homebrew**, and **AI agent configurations** (Claude Code, Antigravity).

## Estructura del repositorio

```text
dotfiles/
├── fish/
│   ├── config.fish        # Homebrew, Starship, mise y carga de los grupos de abreviaciones habilitados
│   ├── fish_plugins       # Plugins gestionados con fisher (plugin-git para las abreviaciones de git)
│   └── abbr/              # Grupos de abreviaciones (git-overrides, docker, strata, antigravity, web, eza)
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
│   ├── mcp.json           # Servidores MCP globales (Playwright, etc.)
│   └── skills/            # Skills compartidas (ponytail, caveman); origen en UPSTREAM.md
├── Brewfile.core          # Núcleo: lo que usan las configuraciones del repo (siempre)
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
| `core`   | Instala lo que falte de `Brewfile.core` con una sola confirmación: fish, fisher, starship, kitty, FiraCode Nerd Font, delta, difftastic, mise y jq. Detecta también lo instalado fuera de Homebrew (app de kitty, fuente, jq del sistema). En Linux, kitty se instala con su instalador oficial en `~/.local/kitty.app`. Nunca desinstala |
| `links`  | Symlinks a `~/.config` y `~/.gitconfig`. Si ya existe un archivo distinto, lo respalda como `<archivo>.bak.<timestamp>` |
| `plugins` | Enlaza `fish/fish_plugins` y sincroniza con `fisher update`. Las abreviaciones de git vienen de `jhillyerd/plugin-git` |
| `tools`  | Checklist del Brewfile: cada paquete aparece marcado si está instalado. Al aplicar, instala lo marcado que falta y desinstala lo desmarcado, previa confirmación. Solo afecta paquetes del Brewfile. Si un paquete tiene un grupo en `fish/abbr/` (su `# Programa:` coincide con el nombre del paquete, p. ej. `eza`), ofrece habilitarlo al instalarlo y deshabilitarlo al desinstalarlo |
| `abbr`   | Checklist de los grupos de `fish/abbr/`: muestra si el programa está instalado (solo informativo) y enlaza los grupos marcados en `~/.config/fish/abbr.d/`, que `config.fish` carga. Los desmarcados se quitan; un archivo propio en esa carpeta no se toca |
| `agents` | Enlaza `agents/` en `~/.agents` y cada skill de `agents/skills/` en `~/.agents/skills` (pi), `~/.claude/skills` y `~/.gemini/skills`, sin tocar skills instaladas a mano. pi: symlink de `AGENTS.md` en `~/.pi/agent` y `mcp.json` **copiado** ahí mismo (pi reescribe ese archivo; del repo solo se sincronizan los servidores que él define y el resto se conserva). Antigravity CLI: symlinks en `~/.gemini/config`. Claude Code: agrega `@~/.agents/AGENTS.md` a `~/.claude/CLAUDE.md` y registra los servidores de `mcp.json` con `claude mcp add-json --scope user`, o los actualiza si su comando difiere del repo (p. ej. al cambiar una versión fijada) |
| `shell`  | Opcional: agrega fish a `/etc/shells` y lo deja como login shell (`chsh`). Kitty abre fish aunque se omita |

¿`Brewfile.core` o `Brewfile`? Si algún archivo del repo usa la herramienta sin comprobar
que exista (p. ej. `delta` como pager en `.gitconfig`), va en `Brewfile.core`; si no, es
opcional y va en `Brewfile`. En ambos, el comentario `#` sobre cada línea es su descripción,
y una línea con `if OS.linux?` o `if OS.mac?` al final solo se usa en ese sistema operativo.

Se puede ejecutar un paso suelto, por ejemplo `./install.sh links` o `./install.sh core tools`.
Ejecutarlo de nuevo es seguro: lo que ya está instalado o enlazado se omite.

Kitty carga `macos.conf` o `linux.conf` automáticamente mediante `include ${KITTY_OS}.conf`.

## Configuración por máquina (fuera del repo)

El repo solo contiene lo global y reutilizable. Lo propio de cada equipo (herramientas
instaladas a mano, su PATH y sus completions) se configura localmente y no se versiona:

| Archivo | Para qué |
|---------|----------|
| `~/.config/fish/conf.d/local.fish` | PATH y variables de esta máquina para fish (fish lo carga automáticamente) |
| `~/.config/fish/completions/*.fish` | Completions de herramientas que no vienen del repo |
| `~/.gitconfig.local` | Ajustes de git de esta máquina, p. ej. la identidad de trabajo. `git/.gitconfig` lo incluye al final, así que sus valores tienen prioridad |
| `~/.zshrc` | Versión mínima con el mismo PATH: Claude Code ejecuta sus comandos en zsh (fish no está soportado), aunque el shell interactivo sea fish |

Si instalas una herramienta a mano, agrega su ruta tanto en `local.fish` como en `~/.zshrc`.
