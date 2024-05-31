#/bin/bash
set -ex
sudo apt update && sudo apt install docker.io postgresql-client make gdb --yes
sudo usermod -aG docker $USER && echo "NOW RELOGIN"
