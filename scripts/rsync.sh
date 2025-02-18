#!/bin/bash
DST_IP=""
PRIV_KEY=""
DST_DIR="~/odyssey/group"

if [ "${DST_IP}" == "" ]; then
    echo "define DST_IP var"
    exit 1
fi

if [ "${PRIV_KEY}" == "" ]; then
    echo "define PRIV_KEY var"
    exit 1
fi
rsync -apv -e "ssh -i ${PRIV_KEY}" --exclude ".git" ./ ${DST_IP}:${DST_DIR} --delete --delete-excluded
