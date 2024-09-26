#!/bin/bash
DST_IP=""
PUB_KEY=""
# ODYSSEY_REPO should end by "/"
# ODYSSEY_REPO=""

if [ "${DST_IP}" == "" ]; then
    echo "define DST_IP var"
    exit 1
fi

if [ "${DST_IP}" == "" ]; then
    echo "define PUB_KEY var"
    exit 1
fi
rsync -apv -e "ssh -i ${PUB_KEY}" --exclude ".git" ./ ${DST_IP}:~/odyssey_group --delete --delete-excluded
# rsync -apv -e "ssh -i ${PUB_KEY}" ${ODYSSEY_REPO} ${DST_IP}:/tmp/odyssey --delete
