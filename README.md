Halo + Siyuan + Caddy + RustDesk

## update
cd && sudo apt update && sudo apt upgrade -y

## install curl (if not installed)
sudo apt install -y curl

## install docker & docker compose
curl -fsSL https://get.docker.com | sh

## comfirm the installation of docker & docker compose
docker --version && docker compose version
