#!/usr/bin/env bash
set -euo pipefail

network_name="${NETWORK:-odyssey-net}"
container_name="${LDAP_CONTAINER:-openldap}"
project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

function run_ldap() {
    NETWORK="$network_name" "$project_dir/scripts/ensure_docker_network.sh"
    docker rm --force "$container_name" 2>/dev/null || true
    docker run --name "$container_name" \
        --network "$network_name" \
        --network-alias ldap.example.local \
        --hostname ldap.example.local \
        -e LDAP_TLS=false \
        -e LDAP_DOMAIN="example.local" \
        -e LDAP_ADMIN_PASSWORD="oD2quooDaimulaegei7w" \
        -e LDAP_CONFIG_PASSWORD="oD2quooDaimulaegei7w" \
        -p 127.0.0.1:389:389 \
        -p 127.0.0.1:636:636 \
        -d osixia/openldap:1.5.0
}

function copy_files() {
    docker cp "$project_dir/configs/ldap_conf/base.ldif" "$container_name:/"
}

function init_data() {
    docker exec "$container_name" bash -c "ldapadd -x -D cn=admin,dc=example,dc=local -f /base.ldif -w oD2quooDaimulaegei7w"
    docker exec "$container_name" bash -c "ldapsearch -x uid=user2 -b ou=people,dc=example,dc=local -D cn=admin,dc=example,dc=local -w oD2quooDaimulaegei7w"
    docker exec "$container_name" bash -c "ldapwhoami -x -D uid=user2,ou=people,dc=example,dc=local -w 654321"
}

function wait_for_ldap() {
    for ((attempt = 1; attempt <= 30; attempt++)); do
        if docker exec "$container_name" ldapwhoami -x \
            -D cn=admin,dc=example,dc=local \
            -w oD2quooDaimulaegei7w >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done

    echo "LDAP did not become ready within 60 seconds" >&2
    docker logs --tail 100 "$container_name" >&2 || true
    return 1
}

run_ldap
wait_for_ldap
copy_files
init_data
