FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moskow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y --no-install-recommends \
    curl \
    git \
    lsb-release \
    ca-certificates \
    libssl-dev \
    libsasl2-dev \
    libldap-common \
    gnupg \
    openssl \
    ldap-utils \
    libldap-dev

RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

RUN apt update && apt install -y --no-install-recommends \
    sudo postgresql-14 \
    build-essential \
    cmake \
    clang \
    gdb \
    libpam0g-dev \
    valgrind \
    libpq5 \
    libpq-dev \
    vim \
    postgresql-common \
    postgresql-server-dev-14

# COPY ./odyssey_repo /odyssey
RUN git clone https://github.com/yandex/odyssey.git /odyssey
workdir /odyssey
RUN sed -i 's/^BUILD_TYPE=Release/BUILD_TYPE=Debug/g' Makefile
RUN make local_build
