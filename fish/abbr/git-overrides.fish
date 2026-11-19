# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: git

# Complementos de jhillyerd/plugin-git (fish_plugins): atajos que el plugin no define.
# Para el resto se usan los del plugin (gcom, gdca, gp!, ...).
abbr -a gmc 'git merge --continue'
abbr -a grhs 'git reset --soft'
abbr -a gp!! 'git push --force-with-lease --no-verify'

# Overrides: el plugin fija `develop`; aquí se usa la rama de desarrollo que tenga el repo,
# igual que gcom usa __git.default_branch.
function __git.develop_branch -d "Primera rama existente (local u origin) entre develop, development y dev; si no, develop"
    for branch in develop development dev
        if command git show-ref -q --verify refs/heads/$branch
            or command git show-ref -q --verify refs/remotes/origin/$branch
            echo $branch
            return
        end
    end
    echo develop
end
abbr -a gcod 'git checkout (__git.develop_branch)'
