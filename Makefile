NETWORK ?= odyssey-net
ODYSSEY_IMAGE ?= odyssey-local
ODYSSEY_CONTAINER ?= odyssey
ODYSSEY_CONFIG ?= base.conf

.PHONY: build_odyssey run_postgres run_ldap run_odyssey stop_odyssey logs_odyssey reload_odyssey console

build_odyssey:
	docker build --tag $(ODYSSEY_IMAGE) .

run_postgres:
	NETWORK=$(NETWORK) ./scripts/run_postgres_container.sh

run_ldap:
	NETWORK=$(NETWORK) ./scripts/run_ldap_container.sh

run_odyssey:
	NETWORK=$(NETWORK) ODYSSEY_IMAGE=$(ODYSSEY_IMAGE) ODYSSEY_CONTAINER=$(ODYSSEY_CONTAINER) ODYSSEY_CONFIG=$(ODYSSEY_CONFIG) ./scripts/run_odyssey_container.sh

stop_odyssey:
	docker rm --force $(ODYSSEY_CONTAINER) 2>/dev/null || true

logs_odyssey:
	docker logs --follow $(ODYSSEY_CONTAINER)

reload_odyssey:
	docker kill --signal HUP $(ODYSSEY_CONTAINER)

console:
	./scripts/connect_mon.sh
