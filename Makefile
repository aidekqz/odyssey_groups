run_postgres:
	./scripts/run_postgres_container.sh

reload_odyssey:
	kill -s HUP `pgrep odyssey`

console:
	./scripts/connect_mon.sh
