restart_container:
	./scripts/run_containers.sh

reload_odyssey:
	kill -s HUP `pgrep odyssey`

console:
	./scripts/connect_mon.sh
