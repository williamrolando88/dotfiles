#!/usr/bin/env bash
# Compatible con bash 3.2 (el bash por defecto de macOS): sin arrays asociativos ni mapfile.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"
OS="$(uname -s)"
ALL_STEPS="kitty fish prompt links shell tools"

usage() {
  cat <<EOF
Uso: ./install.sh [paso ...]

Sin argumentos ejecuta todos los pasos en orden. Cada paso detecta lo que ya
existe y pregunta antes de instalar o cambiar algo.

  kitty    Terminal Kitty
  fish     Shell Fish
  prompt   Starship y FiraCode Nerd Font
  links    Symlinks de configuración (respalda archivos existentes)
  shell    Cambiar el login shell a fish (opcional, requiere sudo)
  tools    Selección interactiva de herramientas del Brewfile
EOF
}

step() {
  echo ""
  echo "==> $1"
}

# Pregunta s/N. En una sesión no interactiva responde siempre No.
confirm() {
  local answer=""
  [ -t 0 ] || return 1
  read -r -p "  $1 (s/N): " answer || true
  [[ "$answer" =~ ^[sS]$ ]]
}

# brew puede no estar en el PATH (p. ej. justo después de instalar Homebrew), así que
# se busca también en los prefijos por defecto: macOS Apple Silicon, macOS Intel, Linuxbrew.
find_brew() {
  local candidate
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return
    fi
  done
  return 1
}

BREW=""
if BREW="$(find_brew)"; then
  # Deja brew y lo que instala en el PATH de este script
  eval "$("$BREW" shellenv bash)"
fi

require_brew() {
  if [ -z "$BREW" ]; then
    echo "  [!] Homebrew no encontrado. Instálalo desde https://brew.sh y vuelve a ejecutar este paso."
    return 1
  fi
}

brew_install() {
  echo "  Ejecutando: brew install $*"
  brew install "$@" || echo "  [!] brew install $* terminó con errores; revisa la salida anterior."
}

# Enlaza src -> dst sin perder datos:
#   - ya enlazado a src      -> no hace nada
#   - symlink a otro destino -> lo reemplaza (el archivo al que apuntaba no se toca)
#   - archivo idéntico a src -> lo reemplaza por el symlink
#   - archivo distinto       -> lo respalda con timestamp (nunca pisa respaldos previos)
link_file() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      echo "  [=] Ya enlazado: $dst"
      return
    fi
    echo "  [~] Reemplazando symlink: $dst (apuntaba a $current)"
    rm "$dst"
  elif [ -e "$dst" ]; then
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      echo "  [~] Contenido idéntico, reemplazando por symlink: $dst"
      rm "$dst"
    else
      local backup
      backup="$dst.bak.$(date +%Y%m%d-%H%M%S)"
      echo "  [!] Respaldando archivo existente: $dst -> $backup"
      mv "$dst" "$backup"
    fi
  fi

  ln -s "$src" "$dst"
  echo "  [OK] Enlazado: $dst -> $src"
}

# Muestra los paquetes del Brewfile con su estado y permite elegir cuáles instalar.
select_brew_packages() {
  local kinds=() names=() descs=() lines=() taps=() desc="" raw

  while IFS= read -r raw || [ -n "$raw" ]; do
    if [[ "$raw" =~ ^#[[:space:]]*(.*)$ ]]; then
      desc="${BASH_REMATCH[1]}"
    elif [[ "$raw" =~ ^tap[[:space:]] ]]; then
      taps+=("$raw")
    elif [[ "$raw" =~ ^(brew|cask|vscode)[[:space:]]+\"([^\"]+)\" ]]; then
      kinds+=("${BASH_REMATCH[1]}")
      names+=("${BASH_REMATCH[2]}")
      descs+=("$desc")
      lines+=("$raw")
      desc=""
    fi
  done < "$BREWFILE"

  local installed_formulae installed_casks installed_ext=""
  installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
  installed_casks="$(brew list --cask -1 2>/dev/null || true)"
  if command -v code >/dev/null 2>&1; then
    installed_ext="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
  fi

  local i status short pending=() statuses=()
  echo ""
  printf "  %3s  %-7s %-34s %-11s %s\n" "#" "Tipo" "Paquete" "Estado" "Descripción"
  for i in "${!names[@]}"; do
    short="${names[$i]##*/}"
    case "${kinds[$i]}" in
      brew)   grep -qxF "$short" <<< "$installed_formulae" && status="instalado" || status="pendiente" ;;
      cask)   grep -qxF "$short" <<< "$installed_casks" && status="instalado" || status="pendiente" ;;
      vscode) grep -qxF "$(echo "$short" | tr '[:upper:]' '[:lower:]')" <<< "$installed_ext" && status="instalado" || status="pendiente" ;;
    esac
    statuses+=("$status")
    [ "$status" = "pendiente" ] && pending+=("$i")
    printf "  %3d  %-7s %-34s %-11s %s\n" "$((i + 1))" "${kinds[$i]}" "${names[$i]}" "$status" "${descs[$i]}"
  done

  if [ "${#pending[@]}" -eq 0 ]; then
    echo ""
    echo "  Todos los paquetes del Brewfile ya están instalados."
    return
  fi

  echo ""
  echo "  Escribe los números a instalar separados por espacio (ej: 1 3 5-7),"
  echo "  'a' para todos los pendientes, o Enter para omitir."
  local answer=""
  read -r -p "  Selección: " answer || true

  local selected=() token start end n
  if [ -z "$answer" ]; then
    echo "  Omitiendo instalación de paquetes."
    return
  elif [ "$answer" = "a" ] || [ "$answer" = "A" ]; then
    selected=("${pending[@]}")
  else
    for token in $answer; do
      if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        start="${BASH_REMATCH[1]}"
        end="${BASH_REMATCH[2]}"
      elif [[ "$token" =~ ^[0-9]+$ ]]; then
        start="$token"
        end="$token"
      else
        echo "  [Aviso] Ignorando entrada no válida: $token"
        continue
      fi
      for ((n = start; n <= end; n++)); do
        if [ "$n" -lt 1 ] || [ "$n" -gt "${#names[@]}" ]; then
          echo "  [Aviso] Fuera de rango: $n"
        elif [ "${statuses[$((n - 1))]}" = "instalado" ]; then
          echo "  [=] Ya instalado, se omite: ${names[$((n - 1))]}"
        else
          selected+=("$((n - 1))")
        fi
      done
    done
  fi

  if [ "${#selected[@]}" -eq 0 ]; then
    echo "  Nada que instalar."
    return
  fi

  # Brewfile temporal solo con lo elegido (y los taps que esos paquetes necesitan)
  local tmp tap tap_name
  tmp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-brewfile.XXXXXX")"
  for tap in ${taps[@]+"${taps[@]}"}; do
    tap_name="$(echo "$tap" | sed -E 's/^tap[[:space:]]+"([^"]+)".*/\1/')"
    for i in "${selected[@]}"; do
      if [[ "${names[$i]}" == "$tap_name/"* ]]; then
        echo "$tap" >> "$tmp"
        break
      fi
    done
  done
  for i in "${selected[@]}"; do
    echo "${lines[$i]}" >> "$tmp"
  done

  echo ""
  echo "==> Instalando selección:"
  sed 's/^/    /' "$tmp"
  brew bundle --file="$tmp" || echo "  [Aviso] brew bundle terminó con errores; revisa la salida anterior."
  rm -f "$tmp"
}

# Kitty puede estar instalado fuera de Homebrew (app descargada, instalador oficial),
# así que además del PATH se revisan sus ubicaciones habituales.
find_kitty() {
  local candidate
  if command -v kitty >/dev/null 2>&1; then
    command -v kitty
    return
  fi
  for candidate in "/Applications/kitty.app/Contents/MacOS/kitty" "$HOME/Applications/kitty.app/Contents/MacOS/kitty" "$HOME/.local/kitty.app/bin/kitty"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return
    fi
  done
  return 1
}

font_installed() {
  if command -v fc-list >/dev/null 2>&1 && grep -qi "FiraCode Nerd Font" <<< "$(fc-list 2>/dev/null)"; then
    return 0
  fi
  # macOS sin fontconfig
  if ls "$HOME/Library/Fonts"/FiraCodeNerdFont* /Library/Fonts/FiraCodeNerdFont* >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

current_login_shell() {
  if [ "$OS" = "Darwin" ]; then
    dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}'
  else
    getent passwd "$(id -un)" | cut -d: -f7
  fi
}

step_kitty() {
  step "Kitty (terminal)"
  local bin
  if bin="$(find_kitty)"; then
    echo "  [=] Ya instalado: $("$bin" --version) ($bin)"
    return
  fi
  require_brew || return 0
  if confirm "Kitty no está instalado. ¿Instalarlo con Homebrew (cask)?"; then
    brew_install --cask kitty
  else
    echo "  Omitido."
  fi
}

step_fish() {
  step "Fish (shell)"
  if command -v fish >/dev/null 2>&1; then
    echo "  [=] Ya instalado: $(fish --version) ($(command -v fish))"
    return
  fi
  require_brew || return 0
  if confirm "Fish no está instalado. ¿Instalarlo con Homebrew?"; then
    brew_install fish
  else
    echo "  Omitido."
  fi
}

step_prompt() {
  step "Starship y FiraCode Nerd Font"
  if command -v starship >/dev/null 2>&1; then
    echo "  [=] Starship ya instalado: $(starship --version | head -1)"
  elif require_brew && confirm "Starship no está instalado. ¿Instalarlo con Homebrew?"; then
    brew_install starship
  else
    echo "  Starship omitido."
  fi

  if font_installed; then
    echo "  [=] FiraCode Nerd Font ya instalada"
  elif require_brew && confirm "FiraCode Nerd Font no está instalada. ¿Instalarla con Homebrew (cask)?"; then
    brew_install --cask font-fira-code-nerd-font
  else
    echo "  Fuente omitida."
  fi
}

step_links() {
  step "Symlinks de configuración"
  # Shell & Terminal (kitty incluye macos.conf o linux.conf según el SO)
  link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
  link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
  link_file "$DOTFILES_DIR/kitty/macos.conf" "$HOME/.config/kitty/macos.conf"
  link_file "$DOTFILES_DIR/kitty/linux.conf" "$HOME/.config/kitty/linux.conf"
  link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

  # Git
  link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

  # Agents / AI Workspaces (Antigravity & Pi)
  link_file "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
  link_file "$DOTFILES_DIR/agents/mcp.json" "$HOME/.agents/mcp.json"
  link_file "$HOME/.agents/mcp.json" "$HOME/.gemini/config/mcp_config.json"
  link_file "$HOME/.agents/AGENTS.md" "$HOME/.gemini/config/GEMINI.md"
}

step_default_shell() {
  step "Login shell (opcional)"
  local fish_path current
  if ! fish_path="$(command -v fish)"; then
    echo "  fish no está instalado; omitiendo."
    return
  fi
  current="$(current_login_shell)"
  if [ "$current" = "$fish_path" ]; then
    echo "  [=] fish ya es el login shell ($fish_path)"
    return
  fi
  echo "  Login shell actual: ${current:-desconocido}. Kitty abre fish aunque no cambies esto."
  if ! confirm "¿Cambiar el login shell a $fish_path? (requiere sudo)"; then
    echo "  Omitido."
    return
  fi
  if ! grep -qxF "$fish_path" /etc/shells; then
    echo "  Agregando $fish_path a /etc/shells"
    echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$fish_path" && echo "  [OK] Login shell cambiado. Aplica en la próxima sesión."
}

step_tools() {
  step "Herramientas del Brewfile"
  require_brew || return 0
  if [ ! -t 0 ]; then
    echo "  Sesión no interactiva: omitiendo selección de paquetes."
    return
  fi
  select_brew_packages
}

run_step() {
  case "$1" in
    kitty)  step_kitty ;;
    fish)   step_fish ;;
    prompt) step_prompt ;;
    links)  step_links ;;
    shell)  step_default_shell ;;
    tools)  step_tools ;;
  esac
}

if [ $# -eq 0 ]; then
  set -- $ALL_STEPS
fi
# Valida todos los pasos antes de ejecutar ninguno
for s in "$@"; do
  case "$s" in
    -h|--help|help)
      usage
      exit 0
      ;;
  esac
  if [[ " $ALL_STEPS " != *" $s "* ]]; then
    echo "Paso desconocido: $s"
    echo ""
    usage
    exit 1
  fi
done

echo "==> Instalando dotfiles desde: $DOTFILES_DIR ($OS, Homebrew: ${BREW:-no encontrado})"

for s in "$@"; do
  run_step "$s"
done

echo ""
echo "==> Listo."
