#!/bin/bash
set -x

psql "host=127.0.0.1 port=6432 user=user1 password=111111 dbname=db1" -c "SELECT 1 AS res" || {
	echo "ERROR: expect good connection"
	exit 1
}
