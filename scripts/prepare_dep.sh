#/bin/bash
set -ex
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install --yes \
    docker.io \
    postgresql-client \
    make \
    cmake \
    bison \
    flex \
    openssl \
    libssl-dev \
    libldap-dev \
    gdb \
    tmux

sudo usermod -aG docker $USER && echo "NOW RELOGIN"
