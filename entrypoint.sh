#!/usr/bin/bash

set -eo pipefail

PIPE=/tmp/vector-koyeb

if [ -z $KOYEB_SERVICE ]; then
    echo "KOYEB_SERVICE must be set"
    exit 1
fi

if [ -z $KOYEB_TOKEN ]; then
    echo "KOYEB_TOKEN must be set"
    exit 1
fi

mkfifo "${PIPE}"

(cat "${PIPE}"|vector) &
koyeb \
    --token "${KOYEB_TOKEN}" \
    --url "${KOYEB_URL:-https://app.koyeb.com}" \
    services logs ${KOYEB_SERVICE} >> "${PIPE}"
