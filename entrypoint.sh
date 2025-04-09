#!/usr/bin/env bash

set -e
set -o pipefail

_FORMAT_LOGS="${FORMAT_LOGS:-"true"}"
_ALLOWED_ADDRESS="${ALLOWED_ADDRESS:-"0.0.0.0"}"

if [[ "$#" -gt 0 ]]; then
    echo "[INFO] Running iamlive with customized arguments: $@"
    exec /app/iamlive "$@"
else
    echo "[INFO] Running iamlive with default arguments."
    if [[ "$_FORMAT_LOGS" = "true" ]]; then
        exec /app/iamlive \
            --output-file "/app/iamlive.log" \
            --mode proxy \
            --bind-addr "${_ALLOWED_ADDRESS}:10080" \
            | jq -c .
    else
        exec /app/iamlive \
            --output-file "/app/iamlive.log" \
            --mode proxy \
            --bind-addr "${_ALLOWED_ADDRESS}:10080"
    fi
fi
