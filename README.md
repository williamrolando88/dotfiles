# dotfiles

Personal dotfiles for William Morales.

Modern developer environment for **macOS and Linux** based on **Fish**, **Kitty**, **Starship**, **FiraCode Nerd Font**, **Homebrew**, and **AI agent configurations** (Claude Code, Antigravity).

## Estructura del repositorio

```text
dotfiles/
├── fish/
│   ├── config.fish        # Homebrew, Starship, mise y carga de los grupos de abreviaciones habilitados
│   ├── fish_plugins       # Plugins gestionados con fisher (plugin-git para las abreviaciones de git)
│   ├── abbr/              # Grupos de abreviaciones (git-overrides, docker, strata, antigravity, web, eza)
│   └── completions/       # Completions para fish (herdr-team)
├── kitty/
│   ├── kitty.conf         # Tema Tokyo Night y FiraCode ligaduras (compartido)
│   ├── macos.conf         # Atajos con cmd, Option como Alt, prefijos de Homebrew
│   └── linux.conf         # Atajos con ctrl, prefijos de Linuxbrew
├── starship/
│   └── starship.toml      # Prompt minimalista con soporte para Git, Bun, Node, Python, etc.
├── git/
│   ├── .gitconfig         # Identidad Git y configuración estándar (rebase = true, main)
│   └── ignore             # Gitignore global (.agents/ para evitar contaminar repos)
├── agents/
│   ├── AGENTS.md          # Instrucciones compartidas para Claude Code y Antigravity
│   ├── mcp.json           # Servidores MCP globales (Playwright, etc.)
│   ├── skills/            # Skills compartidas (ponytail, caveman); origen en UPSTREAM.md
│   └── teams/             # Sistema portable de agentes (herdr-team, roles, templates, presets)
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
| `links`  | Symlinks a `~/.config` y `~/.gitconfig` (incluyendo `git/ignore` global y `fish/completions/herdr-team.fish`). Si ya existe un archivo distinto, lo respalda como `<archivo>.bak.<timestamp>` |
| `plugins` | Enlaza `fish/fish_plugins` y sincroniza con `fisher update`. Las abreviaciones de git vienen de `jhillyerd/plugin-git` |
| `tools`  | Checklist del Brewfile: cada paquete aparece marcado si está instalado. Al aplicar, instala lo marcado que falta y desinstala lo desmarcado, previa confirmación. Solo afecta paquetes del Brewfile. Si un paquete tiene un grupo en `fish/abbr/` (su `# Programa:` coincide con el nombre del paquete, p. ej. `eza`), ofrece habilitarlo al instalarlo y deshabilitarlo al desinstalarlo |
| `abbr`   | Checklist de los grupos de `fish/abbr/`: muestra si el programa está instalado (solo informativo) y enlaza los grupos marcados en `~/.config/fish/abbr.d/`, que `config.fish` carga. Los desmarcados se quitan; un archivo propio en esa carpeta no se toca |
| `agents` | Enlaza `agents/` en `~/.agents`, el binario `herdr-team` en `~/.local/bin/` y las bibliotecas de roles, templates y presets en `~/.agents/`. Configura skills globales (pi, Claude, Antigravity) y servidores MCP. Valida el frontmatter de cada skill y avisa de `/reload` para sesiones abiertas |
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

## Equipos Multi-Agente (`herdr-team`)

El repositorio incluye la herramienta CLI `herdr-team` para inicializar y orquestar equipos de agentes autónomos en cualquier proyecto utilizando **Herdr Core (`hc`)** y la interfaz gráfica **Herdr GUI (`herdr-app`)**.

### Instalación y Actualización en el Sistema
Para habilitar el CLI, el autocompletado y el `.gitignore` global en una máquina existente o tras clonar el repo:
```bash
./install.sh links agents
```
Esto realiza:
- Enlace del comando ejecutable a `~/.local/bin/herdr-team` (disponible en `$PATH`).
- Enlace del catálogo global de roles, templates y presets a `~/.agents/`.
- Configuración de `~/.config/git/ignore` con regla `.agents/` (los repositorios de trabajo nunca se contaminan ni commitean artefactos de agentes).
- Autocompletado interactivo de Fish en `~/.config/fish/completions/herdr-team.fish`.

### Flujo de Trabajo en un Proyecto
1. Pararse en el repositorio de trabajo:
   ```fish
   cd ~/repos/mi-proyecto
   ```
2. Inicializar el equipo de agentes:
   ```fish
   herdr-team init
   # o forzar reemplazo limpio:
   herdr-team init --force
   ```
3. Arrancar el equipo:
   ```fish
   # Modo visual con pestañas en Herdr GUI:
   herdr-team start --ui

   # Con objetivo inicial enviado al Technical Owner:
   herdr-team start --ui --task "Diseñar arquitectura del módulo de pagos"

   # Modo terminal directo:
   herdr-team start --attach
   ```

### Subcomandos Principales
| Comando | Descripción |
|---------|-------------|
| `herdr-team init [--preset <name>]` | Inicializa `.agents/` desde la plantilla base (default: `fullstack`). Limpia cualquier instalación previa. |
| `herdr-team start [--ui] [--task <meta>]` | Levanta los agentes persistentes en `hc` y monta las pestañas en `herdr-app`. |
| `herdr-team status` | Consulta el estado de las terminales activas y los espacios en la GUI de Herdr. |
| `herdr-team restart` | Soft-reset de especialistas persistentes (`/clear` de contexto y re-adopción de persona). |
| `herdr-team stop` | Detiene especialistas efímeros huérfanos y muestra resumen. |

### Roles Soportados en el Preset Base (`fullstack`)
- **`technical-owner` (persistente, `agy`):** Árbitro de producto, punto de contacto con el humano y gestión de PRs.
- **`lead-architect` (persistente, `agy`):** Dueño de contratos, integración del sistema y orquestación técnica.
- **`backend-architect` (persistente, `agy`):** Revisor crítico de APIs, servicios y dimensionamiento backend.
- **`frontend-architect` (persistente, `agy`):** Revisor crítico de interfaces React, estado y DX frontend.
- **`ui-ux-designer` (efímero, `agy`):** Ergonomía móvil-first ($\ge 44\text{px}$), Storybook stories o Markdown specs, y debate tripartito.
- **`implementer-backend` / `implementer-frontend` (efímeros, `pi`):** Implementadores de código acotado y pruebas unitarias.
- **`qa-engineer` (efímero, `pi`):** Validador E2E con Playwright y reportes de aceptación.
- **`infra-specialist` (efímero, `pi`):** DevOps, contenedores Docker y configuraciones de red.

