#!/usr/bin/env bash
set -euo pipefail

network_name="${NETWORK:-odyssey-net}"
container_name="${ODYSSEY_CONTAINER:-odyssey}"
image_name="${ODYSSEY_IMAGE:-odyssey-local}"
config_name="${ODYSSEY_CONFIG:-base.conf}"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_path="$project_dir/configs/$config_name"
certs_path="$project_dir/certs"
core_dir="${ODYSSEY_CORE_DIR:-$project_dir/cores}"

if [[ "$core_dir" != /* ]]; then
    core_dir="$project_dir/$core_dir"
fi

declare -a mount_args=(
    -v "$config_path:/etc/odyssey/odyssey.conf:ro"
    -v "$core_dir:/var/lib/odyssey/cores"
)
declare -a user_args=()

if [[ ! -f "$config_path" ]]; then
    echo "Odyssey configuration does not exist: $config_path" >&2
    exit 1
fi

if [[ "$config_name" == "base.conf" ]] && [[ ! -f "$certs_path/server.crt" || ! -f "$certs_path/server.key" ]]; then
    echo "TLS certificates are missing. Run '$project_dir/scripts/issue_odyssey_tls_cert.sh' first." >&2
    exit 1
fi

if [[ "$config_name" == "base.conf" ]]; then
    mount_args+=(-v "$certs_path:/etc/odyssey/certs:ro")
    # The generated key is readable only by its host owner (mode 0600).
    # Run as that user so Odyssey can read the bind-mounted key.
    user_args=(--user "$(id -u):$(id -g)")
fi

if ! docker image inspect "$image_name" >/dev/null 2>&1; then
    echo "Odyssey image does not exist: $image_name. Run 'make build_odyssey' first." >&2
    exit 1
fi

mkdir -p "$core_dir"
# The image normally runs as UID 1001, but base.conf uses the host UID so it
# can read the TLS key.  Allow either process to create a dump in this local,
# deliberately dedicated directory.
chmod 1777 "$core_dir"

NETWORK="$network_name" "$project_dir/scripts/ensure_docker_network.sh"
docker rm --force "$container_name" >/dev/null 2>&1 || true

exec docker run \
    --name "$container_name" \
    --network "$network_name" \
    --ulimit core=-1 \
    --workdir /var/lib/odyssey/cores \
    -p 127.0.0.1:6432:6432 \
    "${mount_args[@]}" \
    "${user_args[@]}" \
    -d "$image_name" \
    "/etc/odyssey/odyssey.conf"
