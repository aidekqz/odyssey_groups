#!/usr/bin/env bash
set -euo pipefail

network_name="${NETWORK:-odyssey-net}"
container_name="${ODYSSEY_CONTAINER:-odyssey}"
image_name="${ODYSSEY_IMAGE:-odyssey-local}"
config_name="${ODYSSEY_CONFIG:-base.conf}"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_path="$project_dir/configs/$config_name"

if [[ ! -f "$config_path" ]]; then
    echo "Odyssey configuration does not exist: $config_path" >&2
    exit 1
fi

if ! docker image inspect "$image_name" >/dev/null 2>&1; then
    echo "Odyssey image does not exist: $image_name. Run 'make build_odyssey' first." >&2
    exit 1
fi

NETWORK="$network_name" "$project_dir/scripts/ensure_docker_network.sh"
docker rm --force "$container_name" >/dev/null 2>&1 || true

exec docker run \
    --name "$container_name" \
    --network "$network_name" \
    -p 127.0.0.1:6432:6432 \
    -v "$config_path:/etc/odyssey/odyssey.conf:ro" \
    -d "$image_name" \
    "/etc/odyssey/odyssey.conf"
