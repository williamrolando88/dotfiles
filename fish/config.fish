if status is-interactive
    # Grupos de abreviaciones habilitados con `./install.sh abbr` (symlinks a fish/abbr/)
    # test -f descarta symlinks rotos (p. ej. un grupo eliminado del repo)
    for file in $__fish_config_dir/abbr.d/*.fish
        test -f $file; and source $file
    end
end

# Added by Antigravity CLI installer
fish_add_path -g $HOME/.local/bin

# Homebrew: usa el brew del PATH o el primero que exista en los prefijos por defecto
# (macOS Apple Silicon, macOS Intel, Linuxbrew)
set -l brew_bin (command -s brew)
if test -z "$brew_bin"
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew $HOME/.linuxbrew/bin/brew
        if test -x $candidate
            set brew_bin $candidate
            break
        end
    end
end
if test -n "$brew_bin"
    $brew_bin shellenv fish | source
end

# Homebrew: vendor completions y functions (p. ej. fisher instalado vía brew)
if set -q HOMEBREW_PREFIX
    if test -d "$HOMEBREW_PREFIX/share/fish/vendor_completions.d"
        and not contains -- "$HOMEBREW_PREFIX/share/fish/vendor_completions.d" $fish_complete_path
        set -p fish_complete_path "$HOMEBREW_PREFIX/share/fish/vendor_completions.d"
    end
    if test -d "$HOMEBREW_PREFIX/share/fish/vendor_functions.d"
        and not contains -- "$HOMEBREW_PREFIX/share/fish/vendor_functions.d" $fish_function_path
        set -a fish_function_path "$HOMEBREW_PREFIX/share/fish/vendor_functions.d"
    end
end

# Initialize Starship prompt
if type -q starship
    starship init fish | source
end

# Initialize zoxide (smarter cd)
if type -q zoxide
    zoxide init fish | source
end

# Initialize mise-en-place
if type -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end
