#!/usr/bin/env bash
set -euo pipefail

image_name="${ODYSSEY_IMAGE:-odyssey-local}"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
core_dir="${ODYSSEY_CORE_DIR:-$project_dir/cores}"
core_name="${CORE:-}"

if [[ -z "$core_name" ]]; then
    echo "Usage: make gdb_core CORE=<core-file>" >&2
    exit 2
fi

if [[ "$core_dir" != /* ]]; then
    core_dir="$project_dir/$core_dir"
fi

if [[ "$core_name" == /* ]]; then
    core_path="$core_name"
else
    core_path="$core_dir/$core_name"
fi

if [[ ! -f "$core_path" ]]; then
    echo "Core dump does not exist: $core_path" >&2
    exit 1
fi

if ! docker image inspect "$image_name" >/dev/null 2>&1; then
    echo "Odyssey image does not exist: $image_name. Run 'make build_odyssey' first." >&2
    exit 1
fi

core_path="$(cd "$(dirname "$core_path")" && pwd)/$(basename "$core_path")"
core_host_dir="$(dirname "$core_path")"
core_file="$(basename "$core_path")"
source_dir="$project_dir/odyssey"
declare -a source_mount_args=()

if [[ -d "$source_dir" ]]; then
    # build_dbg records /src/... paths in DWARF.  Mount the checkout there so
    # gdb can show the corresponding source lines.
    source_mount_args=(-v "$source_dir:/src:ro")
else
    echo "Odyssey sources are unavailable; gdb will show symbols but not source lines." >&2
fi

exec docker run --rm -it \
    --entrypoint gdb \
    -v "$core_host_dir:/var/lib/odyssey/cores:ro" \
    "${source_mount_args[@]}" \
    "$image_name" \
    -q /usr/local/bin/odyssey "/var/lib/odyssey/cores/$core_file"
