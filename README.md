# test odyssey groups
## prepare
```sh
cp ./env_example ./env
# vim ./env
```
## on vm
```sh
./scripts/prepare_dep.sh
```
## run
```sh
make build_odyssey
make run
make run_test
```
