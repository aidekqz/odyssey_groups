rsync:
	./rsync.sh

build_odyssey:
	docker build -t test_odyssey:0.1 -f Dockerfile .

build_odyssey_rebuild:
	docker build -t test_odyssey:0.1 --no-cache -f Dockerfile .

get_bin:
	docker run --name test_odyssey_tmp -d --rm test_odyssey:0.1 sleep 100
	docker cp test_odyssey_tmp:/odyssey/build/sources/odyssey ./
	docker rm --force test_odyssey_tmp

run: get_bin
	bash run.sh

run_test:
	./test_group.sh

pg_logs:
	docker logs -f postgres

odyssey_logs:
	tail -f odyssey.log

restart_odyssey: get_bin
	pkill odyssey; ./odyssey ./config_group.conf 2>/dev/null
