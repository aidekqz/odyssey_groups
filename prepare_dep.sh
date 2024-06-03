#/bin/bash
set -ex
sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt install docker.io postgresql-client make gdb --yes
sudo usermod -aG docker $USER && echo "NOW RELOGIN"
