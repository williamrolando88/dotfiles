# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: strata

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
