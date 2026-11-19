# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: strata

# Configuración base: Qwen 3.8 Flash Next Abliterated v2 (GSQ-RCO IQ2_XS)
set -l _strata_model "$HOME/modelos/qwen-strata-v2/IQ2_XS"
set -l _strata_cvec "$HOME/modelos/qwen-strata-v2/Huihui-Qwen3.8-Flash-Next-refusal-direction-r-v2.gguf"
set -l _strata_base_args --model-path $_strata_model --context 256k --kv q4_0 --parallel 1 --vision cpu --set control-vector-scaled=$_strata_cvec:1.0 --set cvec-mode=project --set cvec-dir=per-layer

abbr -a sl "strata launch $_strata_base_args --open"
abbr -a sld "strata launch $_strata_base_args --no-tui"
abbr -a sstop 'strata launch --stop'
abbr -a sst 'strata launch --status'
abbr -a sc 'strata connect'
abbr -a strata-start 'sl'

# Strata wrapper for intuitive start/stop subcommands
function strata -d "Strata wrapper with start/stop shortcuts"
    set -l _model "$HOME/modelos/qwen-strata-v2/IQ2_XS"
    set -l _cvec "$HOME/modelos/qwen-strata-v2/Huihui-Qwen3.8-Flash-Next-refusal-direction-r-v2.gguf"
    set -l _base_args --model-path $_model --context 256k --kv q4_0 --parallel 1 --vision cpu --set control-vector-scaled=$_cvec:1.0 --set cvec-mode=project --set cvec-dir=per-layer

    if test (count $argv) -gt 0
        switch $argv[1]
            case start
                command strata launch $_base_args --open $argv[2..-1]
            case stop
                command strata launch --stop
            case '*'
                command strata $argv
        end
    else
        command strata
    end
end
