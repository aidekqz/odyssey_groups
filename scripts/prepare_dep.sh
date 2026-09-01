#!/usr/bin/env bash
set -euxo pipefail

sudo apt-get update
sudo env DEBIAN_FRONTEND=noninteractive apt-get install --yes \
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

sudo usermod -aG docker "${USER:?USER is not set}"
echo "NOW RELOGIN"
