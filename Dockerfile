# Build context: repository root.  The local Odyssey checkout is expected at
# ./odyssey (see README.md); it is intentionally not committed to this repo.
FROM debian:trixie-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    make \
    libssl-dev \
    libpam0g-dev \
    libldap-dev \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY odyssey/ ./

RUN make build_release

FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libldap-dev \
    libpam0g \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 odyssey \
    && useradd --uid 1001 --gid odyssey --no-create-home --shell /usr/sbin/nologin odyssey

COPY --from=build /src/build/sources/odyssey /usr/local/bin/odyssey
COPY configs/base.conf /etc/odyssey/odyssey.conf

USER odyssey
WORKDIR /tmp
EXPOSE 6432

ENTRYPOINT ["/usr/local/bin/odyssey"]
CMD ["/etc/odyssey/odyssey.conf"]
