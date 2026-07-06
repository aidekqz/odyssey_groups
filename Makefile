run_postgres:
	./scripts/run_postgres_container.sh

run_ldap:
	./scripts/run_ldap_container.sh

reload_odyssey:
	kill -s HUP `pidof odyssey_bin`

console:
	./scripts/connect_mon.sh
