# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: git

# Overrides sobre jhillyerd/plugin-git (fish_plugins). El plugin crea sus abreviaciones en
# conf.d, antes de config.fish, así que estas definiciones lo reemplazan.
# gcm y gcd usan los helpers del plugin para detectar la rama principal y la de desarrollo.
abbr -a gcm 'git checkout (__git.default_branch)'
abbr -a gcd 'git checkout (__git.develop_branch)'
abbr -a gds 'git diff --staged'
abbr -a gpf 'git push --force-with-lease'
abbr -a gmc 'git merge --continue'
abbr -a grhs 'git reset --soft'
