# test odyssey groups

## prepare vm

```sh
bash scripts/prepare_dep.sh
```

## build odyssey

```sh
git submodule update
cd odyssey
# make local_build
# make build_dbg
make build_asan
cp ./build/sources/odyssey ../odyssey_bin
cd ..
```
## run pg and odyssey
```sh
make run_postgres
./odyssey/build/sources/odyssey ./configs/base.conf
```

## tmp
```sh
ulimit -c unlimited
sudo sysctl -w kernel.core_pattern="/var/cores/core.%e.%p"
```
