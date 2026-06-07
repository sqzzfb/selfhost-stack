Halo + Siyuan + Caddy + RustDesk

## update system
sudo apt update && sudo apt upgrade -y

## install curl (if not installed)
sudo apt install -y curl

## install docker & docker compose
curl -fsSL https://get.docker.com | sh

## confirm the installation of docker & docker compose
docker --version && docker compose version

## go to home directory
cd ~

## create docker-compose.yml (paste → Ctrl+O → Enter → Ctrl+X)
nano docker-compose.yml

## create Caddyfile (paste → Ctrl+O → Enter → Ctrl+X)
mkdir -p ~/caddy && nano ~/caddy/Caddyfile

## start containers
docker compose up -d

## stop containers (keep containers)
docker compose stop

## stop and remove containers
docker compose down

## update images and restart
docker compose pull && docker compose up -d

## clean up unused images
docker image prune -f

## check container status
docker compose ps

## check logs
docker logs <container_name> --tail=30

## check rustdesk key
docker logs hbbs | grep key
