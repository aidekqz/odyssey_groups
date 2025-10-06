rsync:
	. ./env && bash scripts/rsync.sh

build_odyssey:
	docker build -t test_odyssey:0.1 -f Dockerfile .

build_odyssey_rebuild:
	docker build -t test_odyssey:0.1 --no-cache -f Dockerfile .

get_bin:
	docker rm --force test_odyssey_tmp || true
	docker run --name test_odyssey_tmp -d --rm test_odyssey:0.1 sleep 100
	docker cp test_odyssey_tmp:/odyssey/build/sources/odyssey ./binary/
	docker rm --force test_odyssey_tmp

restart_container:
	./scripts/run_containers.sh

reload_odyssey:
	kill -s HUP `pgrep odyssey`

console:
	./scripts/connect_mon.sh
