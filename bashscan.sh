#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

target="$1"

for port in $(seq 1 65535); do
    timeout 1 bash -c "echo >/dev/tcp/$target/$port" >/dev/null 2>&1 && echo "$port/tcp open"
done
