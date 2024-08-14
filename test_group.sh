#!/bin/bash
set -x

psql "host=127.0.0.1 port=6432 user=user1 password=user1123 dbname=db1" -c "SELECT current_user AS res" || {
	echo "ERROR: expect good connection"
	exit 1
}
