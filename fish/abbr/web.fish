# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: lsof

# Libera un puerto TCP ocupado (ej. killport 3000)
function killport --description "Mata el proceso que escucha en un puerto TCP"
    if test (count $argv) -eq 0
        echo "Uso: killport <puerto>"
        return 1
    end

    set -l pids (lsof -ti tcp:$argv[1])
    if test -z "$pids"
        echo "No hay procesos escuchando en el puerto $argv[1]"
        return 0
    end

    kill -9 $pids
end

abbr -a kp 'killport'
