#!/usr/bin/env bash

action() {
    echo "Action executed at $(date)"
    PGPASSWORD=user1123 psql -h localhost -p 6432 -U user1 db1 -c "select 1"

}

FLAG="/tmp/flag"

while [[ -f "$FLAG" ]]; do
    action
    sleep 1
done

echo "flag $FLAG deleted, exit"
