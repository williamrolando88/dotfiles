if status is-interactive
    # Antigravity
    abbr -a agy-auto 'agy --dangerously-skip-permissions'

    # Git (Oh My Zsh parity)
    abbr -a g 'git'
    abbr -a gst 'git status'
    abbr -a gss 'git status -s'
    abbr -a ga 'git add'
    abbr -a gaa 'git add --all'
    abbr -a gapa 'git add --patch'
    abbr -a gc 'git commit -v'
    abbr -a gca 'git commit -v -a'
    abbr -a 'gcan!' 'git commit --verbose --all --no-edit --amend'
    abbr -a gcmsg 'git commit -m'
    abbr -a gco 'git checkout'
    abbr -a gcb 'git checkout -b'
    abbr -a gcd 'git checkout (git_develop_branch)'
    abbr -a gcm 'git checkout (git_main_branch)'
    abbr -a gb 'git branch'
    abbr -a gba 'git branch -a'
    abbr -a gbd 'git branch -d'
    abbr -a gbD 'git branch -D'
    abbr -a gd 'git diff'
    abbr -a gds 'git diff --staged'
    abbr -a gl 'git pull'
    abbr -a gp 'git push'
    abbr -a gpf 'git push --force-with-lease'
    abbr -a glog 'git log --oneline --decorate --graph'
    abbr -a gsta 'git stash push'
    abbr -a gstp 'git stash pop'
    abbr -a gm 'git merge'
    abbr -a gma 'git merge --abort'
    abbr -a gmc 'git merge --continue'
    abbr -a gmom 'git merge origin/(git_main_branch)'
    abbr -a grb 'git rebase'
    abbr -a grbi 'git rebase -i'
    abbr -a grba 'git rebase --abort'
    abbr -a grbc 'git rebase --continue'
    abbr -a grs 'git restore'
    abbr -a grss 'git restore --source'
    abbr -a grst 'git restore --staged'
    abbr -a grhs 'git reset --soft'
    abbr -a grhh 'git reset --hard'
    abbr -a gignore 'git update-index --assume-unchanged'
    abbr -a gunignore 'git update-index --no-assume-unchanged'

    # Git helper functions (for gcd, gmom, gwip/gunwip)
    function git_main_branch -d "Get default/main branch name"
        command git rev-parse --git-dir >/dev/null 2>&1; or return
        for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}
            if command git show-ref -q --verify $ref
                string split -r -m1 / $ref | tail -n1
                return 0
            end
        end
        for remote in origin upstream
            set -l ref (command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
            if string match -q "$remote/*" -- $ref
                string sub -s (math (string length $remote) + 2) -- $ref
                return 0
            end
        end
        echo master
        return 1
    end

    function git_develop_branch -d "Get develop branch name"
        command git rev-parse --git-dir >/dev/null 2>&1; or return
        for branch in dev devel develop development
            if command git show-ref -q --verify refs/heads/$branch
                echo $branch
                return 0
            end
        end
        echo develop
        return 1
    end

    function gwip -d "git commit a work-in-progress branch"
        git add -A
        set -l deleted (git ls-files --deleted 2>/dev/null)
        if test (count $deleted) -gt 0
            git rm $deleted >/dev/null 2>&1
        end
        git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
    end

    function gunwip -d "git uncommit a work-in-progress branch"
        git log -n 1 | grep -q -c "\--wip--"; and git reset HEAD~1
    end

    # Docker (Oh My Zsh parity)
    abbr -a d 'docker'
    abbr -a dps 'docker ps'
    abbr -a dpa 'docker ps -a'
    abbr -a di 'docker images'
    abbr -a dex 'docker exec -it'
    abbr -a drm 'docker rm'
    abbr -a drmi 'docker rmi'
    abbr -a dstop 'docker stop'
    abbr -a dprune 'docker system prune'

    # Docker Compose (Oh My Zsh parity)
    abbr -a dco 'docker compose'
    abbr -a dcup 'docker compose up'
    abbr -a dcupd 'docker compose up -d'
    abbr -a dcupb 'docker compose up --build'
    abbr -a dcupdb 'docker compose up -d --build'
    abbr -a dcdn 'docker compose down'
    abbr -a dcdnv 'docker compose down -v'
    abbr -a dcl 'docker compose logs -f'
    abbr -a dcb 'docker compose build'
    abbr -a dcr 'docker compose restart'
    abbr -a dcps 'docker compose ps'

    # Strata (Modelo Local - Qwen 3.8 Flash Next)
    abbr -a sl 'strata launch --model-path ~/models/qwen3.8-uncensored --context 256k --kv q4_0 --parallel 1 --open'
    abbr -a sld 'strata launch --model-path ~/models/qwen3.8-uncensored --context 256k --kv q4_0 --parallel 1 --no-tui'
    abbr -a sstop 'strata launch --stop'
    abbr -a sst 'strata launch --status'
    abbr -a sc 'strata connect'
    abbr -a strata-start 'sl'

    # Strata wrapper for intuitive start/stop subcommands
    function strata -d "Strata wrapper with start/stop shortcuts"
        if test (count $argv) -gt 0
            switch $argv[1]
                case start
                    command strata launch --model-path ~/models/qwen3.8-uncensored --context 256k --kv q4_0 --open $argv[2..-1]
                case stop
                    command strata launch --stop
                case '*'
                    command strata $argv
            end
        else
            command strata
        end
    end
end

# Added by Antigravity CLI installer
set -gx PATH "$HOME/.local/bin" $PATH
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

# Homebrew completions for fish
if test -d "$HOMEBREW_PREFIX/share/fish/vendor_completions.d"
    set -p fish_complete_path "$HOMEBREW_PREFIX/share/fish/vendor_completions.d"
end

# Initialize Starship prompt
starship init fish | source

# Initialize mise-en-place
if status is-interactive
    mise activate fish | source
else
    mise activate fish --shims | source
end
