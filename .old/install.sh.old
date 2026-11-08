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

inject_source() {
  local line="$1"
  local target="$HOME/.zshrc"

  if grep -qF "$line" "$target" 2>/dev/null; then
    echo "Already present in .zshrc: $line"
  else
    echo "$line" >> "$target"
    echo "Injected into .zshrc: $line"
  fi
}

link ".gitconfig"

mkdir -p "$HOME/.zsh"
link ".zsh/git-stack.zsh"

inject_source "source ~/.zsh/git-stack.zsh"

echo "Done. Reload your shell:"
echo ""
echo "  source ~/.zshrc"
echo ""
