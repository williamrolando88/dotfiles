#!/usr/bin/env bash
# Compatible con bash 3.2 (el bash por defecto de macOS): sin arrays asociativos ni mapfile.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"
BREWFILE_CORE="$DOTFILES_DIR/Brewfile.core"
ABBR_DIR="$HOME/.config/fish/abbr.d"
OS="$(uname -s)"
ALL_STEPS="core links plugins tools abbr agents shell"

usage() {
  cat <<EOF
Uso: ./install.sh [paso ...]

Sin argumentos ejecuta todos los pasos en orden. Cada paso detecta lo que ya
existe y pregunta antes de instalar o cambiar algo.

  core     Lo que usan las configuraciones del repo (Brewfile.core): fish, kitty,
           starship, FiraCode Nerd Font, fisher, delta, difftastic, mise, jq
  links    Symlinks de configuración (respalda archivos existentes)
  plugins  Plugins de fish con fisher (fish/fish_plugins, p. ej. plugin-git)
  tools    Checklist del Brewfile: instala lo marcado y desinstala lo desmarcado
  abbr     Checklist de grupos de abreviaciones de fish (git-overrides, docker, ...)
  agents   AGENTS.md y MCP para Claude Code y Antigravity
  shell    Cambiar el login shell a fish (opcional, requiere sudo)
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

brew_list_installed() {
  installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
  installed_casks="$(brew list --cask -1 2>/dev/null || true)"
}

# Lee un Brewfile y llena los arrays `kinds names descs lines taps` de la función que la
# llama (scope dinámico, igual que toggle_checked). El comentario `#` sobre cada línea es
# su descripción. Entradas con `if OS.linux?` / `if OS.mac?` solo se leen en ese SO.
read_brewfile() {
  local file="$1" desc="" raw kind pkg
  while IFS= read -r raw || [ -n "$raw" ]; do
    if [[ "$raw" =~ ^#[[:space:]]*(.*)$ ]]; then
      desc="${BASH_REMATCH[1]}"
    elif [[ "$raw" =~ ^tap[[:space:]] ]]; then
      taps+=("$raw")
    elif [[ "$raw" =~ ^(brew|cask|vscode)[[:space:]]+\"([^\"]+)\" ]]; then
      kind="${BASH_REMATCH[1]}"
      pkg="${BASH_REMATCH[2]}"
      if { [[ "$raw" =~ if[[:space:]]+OS\.linux\? ]] && [ "$OS" != "Linux" ]; } ||
         { [[ "$raw" =~ if[[:space:]]+OS\.mac\? ]] && [ "$OS" != "Darwin" ]; }; then
        desc=""
        continue
      fi
      kinds+=("$kind")
      names+=("$pkg")
      descs+=("$desc")
      lines+=("$raw")
      desc=""
    fi
  done < "$file"
}

# Instala con `brew bundle` solo las entradas indicadas (índices de los arrays que llenó
# read_brewfile), más los taps que esas entradas necesitan.
bundle_install() {
  local tmp tap tap_name i
  tmp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-brewfile.XXXXXX")"
  for tap in ${taps[@]+"${taps[@]}"}; do
    tap_name="$(echo "$tap" | sed -E 's/^tap[[:space:]]+"([^"]+)".*/\1/')"
    for i in "$@"; do
      if [[ "${names[$i]}" == "$tap_name/"* ]]; then
        echo "$tap" >> "$tmp"
        break
      fi
    done
  done
  for i in "$@"; do
    echo "${lines[$i]}" >> "$tmp"
  done
  brew bundle --file="$tmp" || echo "  [!] brew bundle terminó con errores; revisa la salida anterior."
  rm -f "$tmp"
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
    if [ "$dst" -ef "$src" ]; then
      echo "  [=] Ya enlazado: $dst"
      return
    fi
    local current
    current="$(readlink "$dst")"
    echo "  [~] Reemplazando symlink: $dst (apuntaba a $current)"
    rm "$dst"
  elif [ -e "$dst" ]; then
    if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      echo "  [~] Contenido idéntico, reemplazando por symlink: $dst"
      rm "$dst"
    elif [ -f "$dst" ] && [ ! -s "$dst" ]; then
      echo "  [~] Archivo vacío, reemplazando por symlink: $dst"
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

# Invierte las posiciones indicadas ("2 4 6-8", base 1) en el array `checked` de la
# función que la llama (bash usa scope dinámico, así funciona también en bash 3.2).
toggle_checked() {
  local answer="$1" total="$2" token start end n
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
      if [ "$n" -lt 1 ] || [ "$n" -gt "$total" ]; then
        echo "  [Aviso] Fuera de rango: $n"
      else
        checked[$((n - 1))]=$((1 - checked[n - 1]))
      fi
    done
  done
}

# Checklist del Brewfile: cada paquete arranca marcado si está instalado. Al aplicar,
# instala lo marcado que falta y desinstala lo desmarcado que está instalado. Nunca toca
# paquetes que no estén en el Brewfile.
sync_brew_packages() {
  local kinds=() names=() descs=() lines=() taps=()
  read_brewfile "$BREWFILE"

  if [ "${#names[@]}" -eq 0 ]; then
    echo "  El Brewfile no tiene paquetes."
    return
  fi

  local installed_formulae installed_casks installed_ext="" has_code=0
  brew_list_installed
  if command -v code >/dev/null 2>&1; then
    has_code=1
    installed_ext="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
  fi

  local i short installed=() checked=()
  for i in "${!names[@]}"; do
    short="${names[$i]##*/}"
    installed[$i]=0
    case "${kinds[$i]}" in
      brew)   grep -qxF "$short" <<< "$installed_formulae" && installed[$i]=1 ;;
      cask)   grep -qxF "$short" <<< "$installed_casks" && installed[$i]=1 ;;
      vscode) grep -qxF "$(echo "$short" | tr '[:upper:]' '[:lower:]')" <<< "$installed_ext" && installed[$i]=1 ;;
    esac
    checked[$i]=${installed[$i]}
  done
  if [ "$has_code" -eq 0 ]; then
    echo "  [Aviso] 'code' no está en el PATH: las extensiones de VS Code aparecen como no instaladas."
  fi

  local answer mark change
  while true; do
    echo ""
    printf "  %-4s %3s  %-7s %-34s %-15s %s\n" "" "#" "Tipo" "Paquete" "Cambio" "Descripción"
    for i in "${!names[@]}"; do
      [ "${checked[$i]}" -eq 1 ] && mark="[x]" || mark="[ ]"
      change=""
      if [ "${checked[$i]}" -eq 1 ] && [ "${installed[$i]}" -eq 0 ]; then
        change="+ instalar"
      elif [ "${checked[$i]}" -eq 0 ] && [ "${installed[$i]}" -eq 1 ]; then
        change="- desinstalar"
      fi
      printf "  %-4s %3d  %-7s %-34s %-15s %s\n" "$mark" "$((i + 1))" "${kinds[$i]}" "${names[$i]}" "$change" "${descs[$i]}"
    done

    echo ""
    echo "  [x] = debe quedar instalado. Escribe números para marcar/desmarcar (ej: 2 4 6-8),"
    echo "  Enter para continuar, o 'q' para salir sin cambios."
    answer=""
    read -r -p "  > " answer || true

    if [ -z "$answer" ]; then
      break
    elif [ "$answer" = "q" ] || [ "$answer" = "Q" ]; then
      echo "  Sin cambios."
      return
    fi

    toggle_checked "$answer" "${#names[@]}"
  done

  local to_install=() to_remove=()
  for i in "${!names[@]}"; do
    if [ "${checked[$i]}" -eq 1 ] && [ "${installed[$i]}" -eq 0 ]; then
      to_install+=("$i")
    elif [ "${checked[$i]}" -eq 0 ] && [ "${installed[$i]}" -eq 1 ]; then
      to_remove+=("$i")
    fi
  done

  if [ "${#to_install[@]}" -eq 0 ] && [ "${#to_remove[@]}" -eq 0 ]; then
    echo "  Sin cambios: lo instalado ya coincide con la selección."
    return
  fi

  echo ""
  echo "  Plan:"
  for i in ${to_install[@]+"${to_install[@]}"}; do
    echo "    + ${kinds[$i]} ${names[$i]}"
  done
  for i in ${to_remove[@]+"${to_remove[@]}"}; do
    echo "    - ${kinds[$i]} ${names[$i]}"
  done
  if ! confirm "¿Aplicar estos cambios?"; then
    echo "  Sin cambios."
    return
  fi

  if [ "${#to_install[@]}" -gt 0 ]; then
    echo ""
    echo "==> Instalando"
    bundle_install "${to_install[@]}"
  fi

  if [ "${#to_remove[@]}" -gt 0 ]; then
    echo ""
    echo "==> Desinstalando"
    for i in "${to_remove[@]}"; do
      case "${kinds[$i]}" in
        brew)   brew uninstall "${names[$i]}" ;;
        cask)   brew uninstall --cask "${names[$i]}" ;;
        vscode) code --uninstall-extension "${names[$i]}" ;;
      esac || echo "  [!] No se pudo desinstalar ${names[$i]} (¿otro paquete depende de él?)"
    done
  fi

  offer_abbr_groups ${to_install[@]+"${to_install[@]}"} -- ${to_remove[@]+"${to_remove[@]}"}
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

# Detecta una entrada del núcleo instalada fuera de Homebrew (app de kitty descargada,
# fuente copiada a mano, fish del sistema, jq de macOS en /usr/bin) para no duplicarla.
core_present_elsewhere() {
  case "$1" in
    kitty)                    find_kitty >/dev/null ;;
    font-fira-code-nerd-font) font_installed ;;
    fisher)                   command -v fish >/dev/null 2>&1 && fish -c 'type -q fisher' 2>/dev/null ;;
    git-delta)                command -v delta >/dev/null 2>&1 ;;
    difftastic)               command -v difft >/dev/null 2>&1 ;;
    *)                        command -v "$1" >/dev/null 2>&1 ;;
  esac
}

# En Linux el cask de kitty no aplica: se usa el instalador oficial, que lo deja en
# ~/.local/kitty.app (find_kitty lo detecta ahí), más los enlaces y el .desktop que
# indica su documentación.
install_kitty_linux() {
  local apps="$HOME/.local/share/applications"
  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n || {
    echo "  [!] El instalador de kitty terminó con errores; revisa la salida anterior."
    return
  }
  mkdir -p "$HOME/.local/bin" "$apps"
  ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/"
  cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" \
     "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$apps/"
  sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$apps"/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" "$apps"/kitty*.desktop
  echo "  [OK] kitty instalado en ~/.local/kitty.app"
}

# Núcleo (Brewfile.core): no es una checklist. Muestra lo que falta y lo instala tras una
# sola confirmación. Nunca desinstala.
step_core() {
  step "Núcleo (Brewfile.core)"
  require_brew || return 0

  local kinds=() names=() descs=() lines=() taps=()
  read_brewfile "$BREWFILE_CORE"

  local installed_formulae installed_casks
  brew_list_installed

  local i short missing=()
  for i in "${!names[@]}"; do
    short="${names[$i]##*/}"
    if { [ "${kinds[$i]}" = "brew" ] && grep -qxF "$short" <<< "$installed_formulae"; } ||
       { [ "${kinds[$i]}" = "cask" ] && grep -qxF "$short" <<< "$installed_casks"; } ||
       core_present_elsewhere "$short"; then
      echo "  [=] ${names[$i]}"
    else
      missing+=("$i")
    fi
  done

  local kitty_missing=0
  if [ "$OS" = "Linux" ] && ! find_kitty >/dev/null; then
    kitty_missing=1
  fi

  if [ "${#missing[@]}" -eq 0 ] && [ "$kitty_missing" -eq 0 ]; then
    echo "  Todo el núcleo está instalado."
    return
  fi

  echo ""
  echo "  Falta:"
  for i in ${missing[@]+"${missing[@]}"}; do
    printf "    + %-26s %s\n" "${names[$i]}" "${descs[$i]}"
  done
  if [ "$kitty_missing" -eq 1 ]; then
    printf "    + %-26s %s\n" "kitty" "Terminal (instalador oficial de kitty)"
  fi
  if ! confirm "¿Instalar lo que falta?"; then
    echo "  Omitido. Las configuraciones del repo pueden fallar sin estas herramientas."
    return
  fi

  if [ "${#missing[@]}" -gt 0 ]; then
    bundle_install "${missing[@]}"
  fi
  if [ "$kitty_missing" -eq 1 ]; then
    install_kitty_linux
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
}

# Claude Code no lee ~/.agents/AGENTS.md ni un mcp.json externo de forma persistente:
# las instrucciones se importan con @ desde ~/.claude/CLAUDE.md y los servidores MCP
# se registran en scope user con `claude mcp add-json`.
setup_claude_code() {
  local claude_md="$HOME/.claude/CLAUDE.md" import_line="@~/.agents/AGENTS.md"

  if [ -f "$claude_md" ] && grep -qxF "$import_line" "$claude_md"; then
    echo "  [=] ~/.claude/CLAUDE.md ya importa AGENTS.md"
  elif confirm "¿Agregar '$import_line' al inicio de ~/.claude/CLAUDE.md?"; then
    mkdir -p "$(dirname "$claude_md")"
    if [ -f "$claude_md" ]; then
      local backup tmp
      backup="$claude_md.bak.$(date +%Y%m%d-%H%M%S)"
      cp "$claude_md" "$backup"
      tmp="$(mktemp "${TMPDIR:-/tmp}/dotfiles-claude-md.XXXXXX")"
      { echo "$import_line"; echo ""; cat "$claude_md"; } > "$tmp"
      cat "$tmp" > "$claude_md"
      rm -f "$tmp"
      echo "  [OK] Import agregado (respaldo: $backup)"
    else
      echo "$import_line" > "$claude_md"
      echo "  [OK] Creado ~/.claude/CLAUDE.md con el import"
    fi
  else
    echo "  Import omitido."
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "  [!] jq no está instalado (ejecuta ./install.sh core); omitiendo el registro de servidores MCP."
    return
  fi
  local name server wanted current
  for name in $(jq -r '.mcpServers | keys[]' "$DOTFILES_DIR/agents/mcp.json"); do
    server="$(jq -c --arg n "$name" '.mcpServers[$n]' "$DOTFILES_DIR/agents/mcp.json")"
    # Se compara solo command + args (Claude agrega campos propios como type y env)
    wanted="$(jq -c --arg n "$name" '.mcpServers[$n] | {command, args}' "$DOTFILES_DIR/agents/mcp.json")"
    current=""
    if [ -f "$HOME/.claude.json" ]; then
      current="$(jq -c --arg n "$name" '.mcpServers // {} | .[$n] // empty | {command, args}' "$HOME/.claude.json")"
    fi

    if [ "$current" = "$wanted" ]; then
      echo "  [=] MCP '$name' ya registrado en Claude Code"
    elif [ -n "$current" ]; then
      echo "  MCP '$name' difiere del repo: $current -> $wanted"
      if confirm "¿Actualizar '$name' en Claude Code (scope user)?"; then
        claude mcp remove --scope user "$name" >/dev/null &&
          claude mcp add-json --scope user "$name" "$server" || echo "  [!] No se pudo actualizar '$name'"
      else
        echo "  MCP '$name' sin cambios."
      fi
    elif confirm "¿Registrar el servidor MCP '$name' en Claude Code (scope user)?"; then
      claude mcp add-json --scope user "$name" "$server" || echo "  [!] No se pudo registrar '$name'"
    else
      echo "  MCP '$name' omitido."
    fi
  done
}

step_agents() {
  step "Agentes de IA (Claude Code y Antigravity)"

  # Fuente única: ~/.agents enlaza a los archivos del repo
  link_file "$DOTFILES_DIR/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
  link_file "$DOTFILES_DIR/agents/mcp.json" "$HOME/.agents/mcp.json"

  # Antigravity lee GEMINI.md y mcp_config.json (mismo formato mcpServers) desde ~/.gemini/config
  if command -v agy >/dev/null 2>&1 || [ -d "$HOME/.gemini" ]; then
    link_file "$HOME/.agents/AGENTS.md" "$HOME/.gemini/config/GEMINI.md"
    link_file "$HOME/.agents/mcp.json" "$HOME/.gemini/config/mcp_config.json"
  else
    echo "  Antigravity no detectado; omitiendo."
  fi

  if command -v claude >/dev/null 2>&1; then
    setup_claude_code
  else
    echo "  Claude Code no detectado; omitiendo."
  fi
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

# Plugins de fish gestionados con fisher. La lista vive en fish/fish_plugins (enlazada en
# ~/.config/fish/fish_plugins), así `fisher install`/`fisher remove` actualizan el repo.
step_plugins() {
  step "Plugins de fish (fisher)"
  if ! command -v fish >/dev/null 2>&1; then
    echo "  fish no está instalado; omitiendo."
    return
  fi

  # Asegura que config.fish esté enlazado para que fish cargue las rutas vendor de Homebrew
  link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"

  if ! fish -c 'type -q fisher' 2>/dev/null; then
    echo "  [!] fisher no está instalado (ejecuta ./install.sh core); omitiendo."
    return
  fi

  link_file "$DOTFILES_DIR/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"

  echo "  Plugins declarados:"
  sed 's/^/    /' "$DOTFILES_DIR/fish/fish_plugins"
  if confirm "¿Sincronizar con 'fisher update' (instala lo listado y quita lo que no esté)?"; then
    fish -c 'fisher update' || echo "  [!] fisher update terminó con errores; revisa la salida anterior."
  else
    echo "  Sincronización omitida."
  fi
}

# Grupos de abreviaciones (fish/abbr/*.fish): habilitar uno lo enlaza en ABBR_DIR, que
# config.fish carga en sesiones interactivas.
abbr_enabled() {
  [ -e "$ABBR_DIR/$1.fish" ] || [ -L "$ABBR_DIR/$1.fish" ]
}

abbr_enable() {
  link_file "$DOTFILES_DIR/fish/abbr/$1.fish" "$ABBR_DIR/$1.fish"
}

# Solo se quitan symlinks creados por el instalador; un archivo propio no se toca
abbr_disable() {
  local src="$DOTFILES_DIR/fish/abbr/$1.fish" dst="$ABBR_DIR/$1.fish"
  if [ -L "$dst" ] && { [ "$dst" -ef "$src" ] || [ "$(readlink "$dst")" = "$src" ]; }; then
    rm "$dst"
    echo "  [OK] Deshabilitado: $1"
  else
    echo "  [!] $dst no es un symlink de este repo; no se modifica."
  fi
}

# Grupos cuyo `# Programa:` coincide con $1 (p. ej. eza -> eza)
abbr_groups_for() {
  local f
  for f in "$DOTFILES_DIR"/fish/abbr/*.fish; do
    [ -f "$f" ] || continue
    if [ "$(sed -n 's/^# Programa:[[:space:]]*//p' "$f")" = "$1" ]; then
      basename "$f" .fish
    fi
  done
}

# Tras instalar o desinstalar paquetes con `tools`, ofrece habilitar o deshabilitar el
# grupo de abreviaciones de cada uno (el que declara `# Programa: <paquete>`). Usa los
# arrays `names` de sync_brew_packages; recibe los índices de cada lista separados por --.
offer_abbr_groups() {
  local i group mode=enable changed=0
  for i in "$@"; do
    if [ "$i" = "--" ]; then
      mode=disable
      continue
    fi
    for group in $(abbr_groups_for "${names[$i]##*/}"); do
      if [ "$mode" = "enable" ]; then
        abbr_enabled "$group" && continue
        command -v "${names[$i]##*/}" >/dev/null 2>&1 || continue
        if confirm "${names[$i]} tiene abreviaciones de fish (grupo '$group'). ¿Habilitarlas?"; then
          abbr_enable "$group"
          changed=1
        fi
      else
        abbr_enabled "$group" || continue
        command -v "${names[$i]##*/}" >/dev/null 2>&1 && continue
        if confirm "${names[$i]} se desinstaló. ¿Deshabilitar sus abreviaciones (grupo '$group')?"; then
          abbr_disable "$group"
          changed=1
        fi
      fi
    done
  done
  if [ "$changed" -eq 1 ]; then
    echo "  Abre una nueva sesión de fish (o ejecuta 'exec fish') para aplicar los cambios."
  fi
}

# Checklist de grupos de abreviaciones. Que el programa esté instalado es solo informativo:
# qué grupos se usan lo decide el usuario (`tools` además los ofrece al instalar).
step_abbr() {
  step "Abreviaciones de fish"
  if [ ! -t 0 ]; then
    echo "  Sesión no interactiva: omitiendo la checklist de abreviaciones."
    return
  fi

  local names=() programs=() counts=() enabled=() checked=() f name program

  # Grupos que ya no existen en el repo: quita sus symlinks rotos (solo los que apuntan aquí)
  for f in "$ABBR_DIR"/*.fish; do
    if [ -L "$f" ] && [ ! -e "$f" ] && [[ "$(readlink "$f")" == "$DOTFILES_DIR/fish/abbr/"* ]]; then
      rm "$f"
      echo "  [~] Quitado grupo eliminado del repo: $(basename "$f" .fish)"
    fi
  done

  for f in "$DOTFILES_DIR"/fish/abbr/*.fish; do
    [ -f "$f" ] || continue
    name="$(basename "$f" .fish)"
    program="$(sed -n 's/^# Programa:[[:space:]]*//p' "$f")"
    names+=("$name")
    programs+=("${program:--}")
    counts+=("$(grep -c '^abbr ' "$f" || true)")
    if abbr_enabled "$name"; then
      enabled+=(1)
    else
      enabled+=(0)
    fi
  done

  if [ "${#names[@]}" -eq 0 ]; then
    echo "  No hay grupos en fish/abbr/."
    return
  fi

  local i
  for i in "${!names[@]}"; do
    checked[$i]=${enabled[$i]}
  done

  local answer mark change installed
  while true; do
    echo ""
    printf "  %-4s %3s  %-14s %-5s %-24s %s\n" "" "#" "Grupo" "Abbr" "Programa" "Cambio"
    for i in "${!names[@]}"; do
      [ "${checked[$i]}" -eq 1 ] && mark="[x]" || mark="[ ]"
      if command -v "${programs[$i]}" >/dev/null 2>&1; then
        installed="${programs[$i]} (instalado)"
      else
        installed="${programs[$i]} (no instalado)"
      fi
      change=""
      if [ "${checked[$i]}" -eq 1 ] && [ "${enabled[$i]}" -eq 0 ]; then
        change="+ habilitar"
      elif [ "${checked[$i]}" -eq 0 ] && [ "${enabled[$i]}" -eq 1 ]; then
        change="- deshabilitar"
      fi
      printf "  %-4s %3d  %-14s %-5s %-24s %s\n" "$mark" "$((i + 1))" "${names[$i]}" "${counts[$i]}" "$installed" "$change"
    done

    echo ""
    echo "  [x] = grupo habilitado. Escribe números para marcar/desmarcar (ej: 1 3),"
    echo "  Enter para continuar, o 'q' para salir sin cambios."
    answer=""
    read -r -p "  > " answer || true

    if [ -z "$answer" ]; then
      break
    elif [ "$answer" = "q" ] || [ "$answer" = "Q" ]; then
      echo "  Sin cambios."
      return
    fi
    toggle_checked "$answer" "${#names[@]}"
  done

  local to_enable=() to_disable=()
  for i in "${!names[@]}"; do
    if [ "${checked[$i]}" -eq 1 ] && [ "${enabled[$i]}" -eq 0 ]; then
      to_enable+=("$i")
    elif [ "${checked[$i]}" -eq 0 ] && [ "${enabled[$i]}" -eq 1 ]; then
      to_disable+=("$i")
    fi
  done

  if [ "${#to_enable[@]}" -eq 0 ] && [ "${#to_disable[@]}" -eq 0 ]; then
    echo "  Sin cambios: los grupos habilitados ya coinciden con la selección."
    return
  fi

  echo ""
  echo "  Plan:"
  for i in ${to_enable[@]+"${to_enable[@]}"}; do
    echo "    + ${names[$i]}"
  done
  for i in ${to_disable[@]+"${to_disable[@]}"}; do
    echo "    - ${names[$i]}"
  done
  if ! confirm "¿Aplicar estos cambios?"; then
    echo "  Sin cambios."
    return
  fi

  for i in ${to_enable[@]+"${to_enable[@]}"}; do
    abbr_enable "${names[$i]}"
  done
  for i in ${to_disable[@]+"${to_disable[@]}"}; do
    abbr_disable "${names[$i]}"
  done
  echo "  Abre una nueva sesión de fish (o ejecuta 'exec fish') para aplicar los cambios."
}

step_tools() {
  step "Herramientas del Brewfile"
  require_brew || return 0
  if [ ! -t 0 ]; then
    echo "  Sesión no interactiva: omitiendo la checklist de herramientas."
    return
  fi
  sync_brew_packages
}

run_step() {
  case "$1" in
    core)   step_core ;;
    links)  step_links ;;
    plugins) step_plugins ;;
    tools)  step_tools ;;
    abbr)   step_abbr ;;
    agents) step_agents ;;
    shell)  step_default_shell ;;
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
