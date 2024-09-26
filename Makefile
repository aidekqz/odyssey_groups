rsync:
	./scripts/rsync.sh

build_odyssey:
# build_odyssey: get_repo
	docker build -t test_odyssey:0.1 -f Dockerfile .

build_odyssey_rebuild:
# build_odyssey_rebuild: get_repo
	docker build -t test_odyssey:0.1 --no-cache -f Dockerfile .

get_bin:
	docker rm --force test_odyssey_tmp || true
	docker run --name test_odyssey_tmp -d --rm test_odyssey:0.1 sleep 100
	docker cp test_odyssey_tmp:/odyssey/build/sources/odyssey ./binary/
	docker rm --force test_odyssey_tmp

restart_container: get_bin
	./scripts/run_containers.sh

run_test:
	./scripts/test_group.sh

pg_logs:
	docker logs -f postgres

odyssey_logs:
	tail -f odyssey.log

restart_odyssey: get_bin
	pkill odyssey; ./binary/odyssey ./configs/gconfig_group.conf 2>/dev/null

reload_odyssey:
	kill -s HUP `pgrep odyssey`

# get_repo:
# 	rm -rf ./odyssey_repo || true
# 	rsync -apP /tmp/odyssey/ ./odyssey_repo
