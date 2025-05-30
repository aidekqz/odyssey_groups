#!/bin/bash

function run_ldap() {
    docker rm --force openldap 2>/dev/null || true
    docker run --name openldap \
        --hostname ldap.example.local \
        -e LDAP_TLS=true \
        -e LDAP_DOMAIN="example.local" \
        -e LDAP_ADMIN_PASSWORD="oD2quooDaimulaegei7w" \
        -e LDAP_CONFIG_PASSWORD="oD2quooDaimulaegei7w" \
        -p 127.0.0.1:389:389 \
        -p 127.0.0.1:636:636 \
        -d osixia/openldap:1.5.0
}

function prepapre_certs() {
    echo "TODO: write code for certs generating"
}

function copy_files() {
    docker cp ./configs/base.ldif openldap:/
}

function init_data() {
    docker exec -it openldap bash -c "ldapadd -x -D cn=admin,dc=example,dc=local -f /base.ldif -w oD2quooDaimulaegei7w"
    docker exec -it openldap bash -c "ldapsearch -x uid=user2 -b ou=people,dc=example,dc=local -D cn=admin,dc=example,dc=local -w oD2quooDaimulaegei7w"
    docker exec -it openldap bash -c "ldapwhoami -x -D uid=user2,ou=people,dc=example,dc=local -w 654321"
}

function my_sleep() {
    echo "sleep ${1}"
    sleep $1
}

prepapre_certs
run_ldap
my_sleep 4
copy_files
init_data
