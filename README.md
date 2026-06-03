# dotfiles

Personal dotfiles for William Morales.

## What's included

| File | Description |
|------|-------------|
| `.gitconfig` | Git config: editor, push/pull defaults, and stacked-branch aliases |

### Git stack aliases

| Alias | Shortcut | Description |
|-------|----------|-------------|
| `git stack` | `git gsk` | List branches in the current stack (from merge-base to HEAD) |
| `git push-stack` | `git gps` | Force-push all branches in the stack |
| `git stack-up` | `git gsku` | Checkout the child branch in the stack |
| `git stack-down` | `git gskd` | Checkout the parent branch in the stack |

Shortcuts are chosen to avoid collisions with the [oh-my-zsh git plugin](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/README.md).

## Install

Run from anywhere:

```sh
bash /path/to/.dotfiles/install.sh
```

The script symlinks each dotfile into `$HOME`, backing up any existing file as `<file>.bak`.

## Extending

To track a new dotfile (e.g. `.zshrc`):

1. Copy the file into this repo:
   ```sh
   cp ~/.zshrc ~/.dotfiles/.zshrc
   ```

2. Add a `link` call at the bottom of `install.sh`:
   ```sh
   link ".zshrc"
   ```

3. Re-run `install.sh` to create the symlink:
   ```sh
   bash ~/.dotfiles/install.sh
   ```

The `link` helper works for any path relative to `$HOME`, including nested ones:

```sh
link ".config/starship.toml"   # creates $HOME/.config/starship.toml → $DOTFILES_DIR/.config/starship.toml
```

Just mirror the same directory structure inside the repo.
