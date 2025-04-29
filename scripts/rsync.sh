#!/bin/bash

if [ "${DST_IP}" == "" ]; then
    echo "define DST_IP env var"
    exit 1
fi

if [ "${PRIV_KEY}" == "" ]; then
    echo "define PRIV_KEY env var"
    exit 1
fi

if [ "${PRIV_KEY}" == "" ]; then
    echo "define DST_USER env var"
    exit 1
fi

if [ "${DST_DIR}" == "" ]; then
    echo "define DST_DIR env var"
    exit 1
fi

rsync -apv -e "ssh -i ${PRIV_KEY}" \
    --exclude ".git" \
    --exclude ".gitignore" \
    --exclude "scripts/rsync.sh" \
    ./ ${DST_USER}@${DST_IP}:${DST_DIR} --delete --delete-excluded
