# Fish completions for herdr-team

# Disable file completions by default
complete -c herdr-team -f

# Global flags
complete -c herdr-team -s h -l help -d "Show help message"

# Subcommands
complete -c herdr-team -n "__fish_use_subcommand" -a init -d "Initialize clean .agents/ in project"
complete -c herdr-team -n "__fish_use_subcommand" -a start -d "Boot or attach to agent team"
complete -c herdr-team -n "__fish_use_subcommand" -a status -d "Show status of agents and Herdr GUI"
complete -c herdr-team -n "__fish_use_subcommand" -a restart -d "Soft-reset persistent specialists"
complete -c herdr-team -n "__fish_use_subcommand" -a stop -d "Stop ephemeral workers and show close guide"
complete -c herdr-team -n "__fish_use_subcommand" -a help -d "Show help message"

# Subcommand: init
complete -c herdr-team -n "__fish_seen_subcommand_from init" -l preset -d "Preset topology to use" -x -a "(test -d ~/.agents/presets && basename -s .json ~/.agents/presets/*.json 2>/dev/null)"
complete -c herdr-team -n "__fish_seen_subcommand_from init" -s f -l force -d "Overwrite existing .agents/ without prompting"
complete -c herdr-team -n "__fish_seen_subcommand_from init" -s h -l help -d "Show help message"

# Subcommand: start
complete -c herdr-team -n "__fish_seen_subcommand_from start" -l ui -d "Mount tabs in Herdr GUI (herdr-app)"
complete -c herdr-team -n "__fish_seen_subcommand_from start" -l task -d "Send initial requirement to technical-owner" -r
complete -c herdr-team -n "__fish_seen_subcommand_from start" -l attach -d "Attach terminal directly to technical-owner"
complete -c herdr-team -n "__fish_seen_subcommand_from start" -l restart -d "Soft-reset persistent specialists before starting"
complete -c herdr-team -n "__fish_seen_subcommand_from start" -l status -d "Show live team status and exit"
complete -c herdr-team -n "__fish_seen_subcommand_from start" -s h -l help -d "Show help message"
