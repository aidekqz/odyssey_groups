#!/usr/bin/env bash
# Issue a local CA and server certificate for the TLS-enabled base config.
#
# Usage: ./scripts/issue_odyssey_tls_cert.sh [--output DIR] [--force]

set -euo pipefail
umask 077

OUTPUT_DIR="./certs"
FORCE=false

usage() {
    cat <<'EOF'
Использование: ./scripts/issue_odyssey_tls_cert.sh [--output DIR] [--force]

Создаёт локальный CA и серверный сертификат Odyssey с SAN localhost и 127.0.0.1.
TLS уже обязателен в configs/base.conf; при запуске базовой конфигурации
каталог ./certs монтируется в контейнер как /etc/odyssey/certs.

По умолчанию файлы помещаются в ./certs:
  ca.crt      корневой сертификат для параметра sslrootcert клиента
  server.crt  сертификат сервера Odyssey
  server.key  закрытый ключ сервера Odyssey

Скрипт не перезаписывает существующие файлы. Для перевыпуска сертификатов
в том же каталоге передайте --force.

Параметр --output полезен для выпуска сертификата в другой каталог, но для
запуска configs/base.conf сертификаты должны находиться в ./certs.
EOF
}

while (($# > 0)); do
    case "$1" in
        --output)
            if (($# < 2)); then
                echo "Для --output требуется путь к каталогу" >&2
                exit 2
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Неизвестный параметр: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! command -v openssl >/dev/null 2>&1; then
    echo "Не найден openssl" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

declare -a output_files=(ca.crt ca.key ca.srl server.crt server.csr server.key)
if [[ "$FORCE" != true ]]; then
    for file in "${output_files[@]}"; do
        if [[ -e "$OUTPUT_DIR/$file" ]]; then
            echo "Файл уже существует: $OUTPUT_DIR/$file. Для перевыпуска используйте --force." >&2
            exit 1
        fi
    done
fi

if [[ "$FORCE" == true ]]; then
    rm -f "$OUTPUT_DIR"/{ca.crt,ca.key,ca.srl,server.crt,server.csr,server.key}
fi

extensions_file=$(mktemp)
trap 'rm -f "$extensions_file"' EXIT

cat >"$extensions_file" <<'EOF'
basicConstraints = critical, CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @subject_alt_name
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[subject_alt_name]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

openssl genrsa -out "$OUTPUT_DIR/ca.key" 4096
openssl req -x509 -new -sha256 -days 3650 \
    -key "$OUTPUT_DIR/ca.key" \
    -out "$OUTPUT_DIR/ca.crt" \
    -subj '/CN=Odyssey local test CA' \
    -addext 'basicConstraints=critical,CA:TRUE,pathlen:0' \
    -addext 'keyUsage=critical,keyCertSign,cRLSign' \
    -addext 'subjectKeyIdentifier=hash'

openssl genrsa -out "$OUTPUT_DIR/server.key" 2048
openssl req -new -sha256 \
    -key "$OUTPUT_DIR/server.key" \
    -out "$OUTPUT_DIR/server.csr" \
    -subj '/CN=localhost'
openssl x509 -req -sha256 -days 825 \
    -in "$OUTPUT_DIR/server.csr" \
    -CA "$OUTPUT_DIR/ca.crt" \
    -CAkey "$OUTPUT_DIR/ca.key" \
    -CAcreateserial \
    -out "$OUTPUT_DIR/server.crt" \
    -extfile "$extensions_file"

rm -f "$OUTPUT_DIR/server.csr" "$OUTPUT_DIR/ca.srl"
chmod 600 "$OUTPUT_DIR/ca.key" "$OUTPUT_DIR/server.key"
chmod 644 "$OUTPUT_DIR/ca.crt" "$OUTPUT_DIR/server.crt"

cat <<EOF
Сертификаты выпущены в $OUTPUT_DIR

TLS уже включён в configs/base.conf. Запустите Odyssey:
    make run_odyssey ODYSSEY_CONFIG=base.conf

Подключение клиента:
    psql "host=127.0.0.1 port=6432 dbname=db1 user=user1 sslmode=verify-ca sslrootcert=$OUTPUT_DIR/ca.crt"
EOF
