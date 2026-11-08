#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Instalando dotfiles desde: $DOTFILES_DIR"

link_file() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  mkdir -p "$dst_dir"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "  Respaldando archivo existente: $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "  [OK] Enlazado: $dst -> $src"
}

# 1. Shell & Terminal
link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# 2. Git
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# 3. Agents / AI Workspaces (Antigravity & Pi)
link_file "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
link_file "$DOTFILES_DIR/agents/mcp.json" "$HOME/.agents/mcp.json"

mkdir -p "$HOME/.gemini/config"
ln -sf "$HOME/.agents/mcp.json" "$HOME/.gemini/config/mcp_config.json"
ln -sf "$HOME/.agents/AGENTS.md" "$HOME/.gemini/config/GEMINI.md"
echo "  [OK] Configurado entorno de agentes en ~/.agents y ~/.gemini/config"

# 4. Homebrew Bundle (Opcional)
if command -v brew >/dev/null 2>&1; then
  echo ""
  read -r -p "¿Deseas instalar los paquetes de Brewfile ahora con Homebrew? (s/N): " install_brew || true
  if [[ "${install_brew:-}" =~ ^[sS]$ ]]; then
    echo "==> Ejecutando brew bundle..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
  else
    echo "  Omitiendo brew bundle. Puedes ejecutarlo luego con: brew bundle --file=$DOTFILES_DIR/Brewfile"
  fi
else
  echo ""
  echo "  [Aviso] Homebrew no detectado en el PATH. Instálalo para usar 'brew bundle --file=$DOTFILES_DIR/Brewfile'."
fi

echo ""
echo "==> ¡Dotfiles instalados exitosamente!"
