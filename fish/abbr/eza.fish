# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: eza

# Listado básico con iconos y carpetas primero
abbr -a l 'eza --icons=always --group-directories-first'
abbr -a ls 'eza --icons=always'

# Detalle largo con estado de Git
abbr -a ll 'eza -l --icons=always --git --group-directories-first'
abbr -a la 'eza -la --icons=always --git --group-directories-first'

# Vista en árbol (tree)
abbr -a lt 'eza --tree --level=2 --icons=always'
abbr -a lta 'eza --tree --level=3 -la --icons=always --git-ignore -I "node_modules|.git|dist|.next" --git'

# Ordenado por fecha de modificación (los cambios más recientes al final)
abbr -a llm 'eza -la --icons=always --git --sort=modified --reverse'

# Filtrar únicamente directorios
abbr -a ld 'eza -lD --icons=always'
