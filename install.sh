#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$1"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -sf "$src" "$dst"
  echo "Linked $dst"
}

link ".gitconfig"

echo "Done."
