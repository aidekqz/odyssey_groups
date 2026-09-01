# Odyssey Docker test bench

Локальный стенд для ручного тестирования [Odyssey](https://github.com/yandex/odyssey), маршрутизации групп ролей PostgreSQL и LDAP-аутентификации. Сервисы запускаются обычными командами `docker`; `docker-compose` не используется.

## Требования

- Docker с доступом текущего пользователя;
- `make` и клиент PostgreSQL (`psql`) для инициализации PostgreSQL и проверок;
- исходный код Odyssey в каталоге `./odyssey`. Этот каталог игнорируется Git, поэтому его нужно получить отдельно:

  ```sh
  git clone https://github.com/yandex/odyssey.git odyssey
  ```

## Быстрый запуск сценария групп ролей

```sh
make build_odyssey
make run_postgres
make run_odyssey ODYSSEY_CONFIG=config_group.conf
./scripts/test_group.sh
```

`make build_odyssey` собирает образ `odyssey-local` в несколько стадий: компиляторы и исходники не попадают в итоговый образ. PostgreSQL и Odyssey запускаются в сети Docker `odyssey-net`; внутри неё Odyssey находит PostgreSQL по имени `postgres`. Снаружи доступны только `127.0.0.1:5432` и `127.0.0.1:6432`.

В образ добавлен `configs/base.conf` как `/etc/odyssey/odyssey.conf`; это и есть конфигурация запуска по умолчанию. Команда `make run_odyssey` монтирует выбранный исходный конфиг поверх этого файла. Выбрать другой конфиг или имя образа можно без изменения файлов; внутри контейнера он всё равно будет доступен как `odyssey.conf`:

```sh
make run_odyssey ODYSSEY_CONFIG=base.conf
make build_odyssey ODYSSEY_IMAGE=odyssey-local:debug
make run_odyssey ODYSSEY_IMAGE=odyssey-local:debug ODYSSEY_CONFIG=config_ldap.conf
```

Полезные команды:

```sh
make logs_odyssey       # поток логов контейнера
make reload_odyssey     # отправить SIGHUP контейнеру
make stop_odyssey       # удалить контейнер Odyssey
make console            # подключиться к административной консоли (base.conf)
```

## LDAP

Для LDAP-сценария сначала поднимите PostgreSQL и LDAP, затем запустите Odyssey с LDAP-конфигурацией:

```sh
make run_postgres
make run_ldap
make run_odyssey ODYSSEY_CONFIG=config_ldap.conf
psql "host=127.0.0.1 port=6432 dbname=db1 user=user2 password=654321"
```

LDAP получает сетевой псевдоним `ldap.example.local`, поэтому Odyssey разрешает это имя внутри сети Docker. `run_ldap` больше не изменяет `/etc/hosts` хоста и не требует `sudo`.

## Примечания

- Скрипты намеренно пересоздают контейнеры `postgres`, `openldap` и `odyssey`; убедитесь, что эти имена не заняты другой работой.
- `make run_postgres` применяет `scripts/init.sql` после готовности базы.
- Конфигурации рассчитаны на запуск Odyssey в контейнере: он слушает `0.0.0.0`, а PostgreSQL указан как `postgres`.
- IAM-сценарий дополнительно требует поставщика сокета IAM-прокси; в этом репозитории его нет. При запуске контейнера сокет нужно отдельно передать в контейнер как volume.
