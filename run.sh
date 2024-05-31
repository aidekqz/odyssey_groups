#!/bin/bash
set -ex
docker rm --force postgres 2>/dev/null || true
docker run --name postgres -e POSTGRES_PASSWORD=123456 -p 127.0.0.1:5432:5432 -d postgres
sleep 5
docker exec -it postgres bash -c "sed -i 's/scram-sha-256/md5/g' /var/lib/postgresql/data/pg_hba.conf"
docker exec -it postgres bash -c "sed -i '1 i\log_connections = on' /var/lib/postgresql/data/postgresql.conf"
docker exec -it postgres bash -c "sed -i '1 i\log_statement = all' /var/lib/postgresql/data/postgresql.conf"
docker exec -it postgres bash -c "sed -i '1 i\log_min_error_statement = debug5' /var/lib/postgresql/data/postgresql.conf"
sleep 2
psql "host=127.0.0.1 port=5432 user=postgres password=123456 dbname=postgres" -f init.sql
pkill odyssey || true
./odyssey ./config.conf
