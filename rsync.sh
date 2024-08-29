#!/bin/bash
DST_IP=""
PUB_KEY=""

if [ "${DST_IP}" == "" ]; then
    echo "define DST_IP var"
    exit 1
fi

if [ "${DST_IP}" == "" ]; then
    echo "define PUB_KEY var"
    exit 1
fi
rsync -apv -e "ssh -i ${PUB_KEY}" --exclude ".git" ./ ${DST_IP}:~/odyssey_group --delete
