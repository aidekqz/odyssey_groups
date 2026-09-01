#!/usr/bin/env bash
set -euo pipefail

network_name="${NETWORK:-odyssey-net}"
container_name="${POSTGRES_CONTAINER:-postgres}"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

NETWORK="$network_name" "$project_dir/scripts/ensure_docker_network.sh"
docker rm --force "$container_name" 2>/dev/null || true

docker run \
  --name "$container_name" \
  --network "$network_name" \
  --network-alias postgres \
  -e POSTGRES_PASSWORD=postgres123 \
  -e POSTGRES_HOST_AUTH_METHOD=md5 \
  -p 127.0.0.1:5432:5432 \
  -d postgres:18.4 \
  -c log_connections=on \
  -c log_statement=all \
  -c password_encryption=md5 \
  -c log_min_error_statement=debug5

for ((attempt = 1; attempt <= 30; attempt++)); do
  if docker exec "$container_name" pg_isready -U postgres >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if ! docker exec "$container_name" pg_isready -U postgres >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready within 60 seconds" >&2
  docker logs --tail 100 "$container_name" >&2 || true
  exit 1
fi

psql "host=127.0.0.1 port=5432 user=postgres password=postgres123 dbname=postgres" \
  -f "$project_dir/scripts/init.sql"
