# Grupo de abreviaciones; se habilita o deshabilita con `./install.sh abbr`
# Programa: docker

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
