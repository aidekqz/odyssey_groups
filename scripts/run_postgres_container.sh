#!/bin/bash
set -ex

docker rm --force postgres 2>/dev/null || true

docker run \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres123 \
  -e POSTGRES_HOST_AUTH_METHOD=md5 \
  -p 127.0.0.1:5432:5432 \
  -d postgres:18.4 \
  -c log_connections=on \
  -c log_statement=all \
  -c password_encryption=md5 \
  -c log_min_error_statement=debug5

until docker exec postgres pg_isready -U postgres; do sleep 2; done

psql "host=127.0.0.1 port=5432 user=postgres password=postgres123 dbname=postgres" \
  -f ./scripts/init.sql
