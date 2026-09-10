# Odyssey Docker test bench

Локальный стенд для ручного тестирования [Odyssey](https://github.com/yandex/odyssey), маршрутизации групп ролей PostgreSQL и LDAP-аутентификации. Сервисы запускаются обычными командами `docker`; `docker-compose` не используется.

## Требования

- Docker с доступом текущего пользователя;
- `make` и клиент PostgreSQL (`psql`) для инициализации PostgreSQL и проверок;
- исходный код Odyssey в каталоге `./odyssey`. Этот каталог игнорируется Git, поэтому его нужно получить отдельно:

  ```sh
  git clone https://github.com/yandex/odyssey.git odyssey
  ```

`make build_odyssey` проверяет наличие `odyssey/Makefile` до запуска Docker и
выведет эту команду, если checkout отсутствует или каталог пуст.

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

## Core dumps Odyssey

`make run_odyssey` запускает контейнер с неограниченным лимитом core и
монтирует локальный каталог `./cores` в его рабочий каталог
`/var/lib/odyssey/cores`. Поэтому дамп, созданный Odyssey при аварийном
завершении, остаётся в `./cores` и после удаления или пересоздания контейнера.
Основной образ собирается через portable-цель Odyssey `make local_build BUILD_TYPE=Debug` в
режиме `Debug` и содержит отладочные символы и `gdb`; он используется и для
обычного запуска, и для разбора core. Откройте
дамп во временном контейнере из того же образа:

```sh
make gdb_core CORE=core.1234
# в gdb: bt
```

Временный контейнер автоматически удаляется после выхода из `gdb`; core-файл
остаётся на хосте. Локальный checkout `./odyssey` монтируется в GDB-контейнер
только для чтения, поэтому доступны также строки исходного кода. Каталог
игнорируется Git. Не пересобирайте или не перетегируйте образ между падением и
разбором: бинарник GDB должен совпадать с тем, который создал core. Для
отдельного сохранённого тега передайте одинаковое значение в обе команды:

```sh
make build_odyssey ODYSSEY_IMAGE=odyssey-local:debug-branch
make run_odyssey ODYSSEY_IMAGE=odyssey-local:debug-branch
make gdb_core ODYSSEY_IMAGE=odyssey-local:debug-branch CORE=core.1234
```

При необходимости укажите другое место для core:

```sh
make run_odyssey ODYSSEY_CORE_DIR=/absolute/path/to/cores
```

Это работает, когда `kernel.core_pattern` на Docker-хосте задаёт имя файла
(например, `core` или `core.%p`). Если он начинается с `|`, ядро передаёт дамп
в внешний обработчик (systemd-coredump, apport и т.п.), и место хранения
определяет этот обработчик, а не контейнер.

## TLS в базовой конфигурации

`configs/base.conf` включает TLS для клиентских подключений. Перед первым
запуском выпустите локальный CA и сертификат сервера:

```sh
./scripts/issue_odyssey_tls_cert.sh
make run_postgres
make run_odyssey ODYSSEY_CONFIG=base.conf
```

`run_odyssey` монтирует каталог `./certs` в контейнер только для базовой
конфигурации. Если сертификаты отсутствуют, запуск завершается с подсказкой
выполнить скрипт выпуска. Подключитесь, доверив клиенту созданный CA:

```sh
psql "host=127.0.0.1 port=6432 dbname=postgres user=postgres sslmode=verify-ca sslrootcert=./certs/ca.crt"
```

Сертификат содержит SAN `localhost` и `127.0.0.1`; поэтому также можно
использовать `sslmode=verify-full` с этими именами хоста.

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

## TODO

- Сделать IAM-сценарий воспроизводимым: добавить команду запуска, проверку и
  монтирование сокета IAM-прокси в контейнер Odyssey.
- Вынести тестовые учётные данные из конфигураций и скриптов в шаблон файла
  окружения; не допускать использования в стенде реальных секретов.
