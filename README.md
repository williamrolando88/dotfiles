# dotfiles

Personal dotfiles for William Morales.

Modern developer environment based on **Fish**, **Kitty**, **Starship**, **Fira Code Nerd Font**, **Homebrew (Linuxbrew)**, and **AI Agent configurations**.

## Estructura del repositorio

```text
dotfiles/
├── .old/                  # Configuraciones previas archivadas (Zsh, scripts anteriores)
├── fish/
│   └── config.fish        # Abreviaciones Git, Docker, Strata y utilidades interactivas
├── kitty/
│   ├── kitty.conf         # Tema Tokyo Night y FiraCode ligaduras (compartido)
│   ├── macos.conf         # Atajos con cmd, Option como Alt, prefijos de Homebrew
│   └── linux.conf         # Atajos con ctrl, prefijos de Linuxbrew
├── starship/
│   └── starship.toml      # Prompt minimalista con soporte para Git, Bun, Node, Python, etc.
├── git/
│   └── .gitconfig         # Identidad Git y configuración estándar (rebase = true, main)
├── agents/
│   ├── AGENTS.md          # Reglas maestras y directrices para agentes de IA
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
| `links`  | Symlinks a `~/.config`, `~/.gitconfig`, `~/.agents` y `~/.gemini/config`. Si ya existe un archivo distinto, lo respalda como `<archivo>.bak.<timestamp>` |
| `shell`  | Opcional: agrega fish a `/etc/shells` y lo deja como login shell (`chsh`). Kitty abre fish aunque se omita |
| `tools`  | Lista el Brewfile con el estado de cada paquete y permite elegir cuáles instalar |

Se puede ejecutar un paso suelto, por ejemplo `./install.sh links` o `./install.sh kitty fish`.
Ejecutarlo de nuevo es seguro: lo que ya está instalado o enlazado se omite.

Kitty carga `macos.conf` o `linux.conf` automáticamente mediante `include ${KITTY_OS}.conf`.
