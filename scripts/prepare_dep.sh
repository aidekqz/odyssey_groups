#/bin/bash
set -ex
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install docker.io docker-buildx postgresql-client make gdb neovim tmux --yes
sudo usermod -aG docker $USER && echo "NOW RELOGIN"
