# test odyssey groups

## prepare vm

```sh
bash scripts/prepare_dep.sh
```

## build odyssey

```sh
git clone https://github.com/yandex/odyssey.git odyssey
cd odyssey
make local_build
```
## run pg and odyssey
```sh
make run_postgres
./odyssey/build/sources/odyssey ./configs/base.conf
```
