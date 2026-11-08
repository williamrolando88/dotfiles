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
│   └── kitty.conf         # Tema Tokyo Night, FiraCode ligaduras y atajos de ventanas/tabs
├── starship/
│   └── starship.toml      # Prompt minimalista con soporte para Git, Bun, Node, Python, etc.
├── git/
│   └── .gitconfig         # Identidad Git y configuración estándar (rebase = true, main)
├── agents/
│   ├── AGENTS.md          # Reglas maestras y directrices para agentes de IA
│   └── mcp.json           # Servidores MCP globales (Playwright, etc.)
├── Brewfile               # Paquetes y herramientas CLI modernas gestionadas con Homebrew
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

El script se encarga de:
- Enlazar automáticamente las configuraciones a `~/.config/fish`, `~/.config/kitty`, `~/.config/starship.toml`, `~/.gitconfig`.
- Vincular las reglas de agentes a `~/.agents/` y `~/.gemini/config/`.
- Ofrecer la instalación desatendida de todas las herramientas CLI mediante `brew bundle`.
