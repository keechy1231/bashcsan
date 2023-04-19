#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

target="$1"
open_ports=""

# Define function to scan ports
scan_port() {
    local port="$1"
    if timeout 1 bash -c "echo >/dev/tcp/$target/$port" >/dev/null 2>&1; then
        if ! echo "$open_ports" | grep -q "\b$port/tcp\b"; then
            open_ports+=" $port/tcp"
            echo -e "\rScanning port $port... \033[0;32m[OPEN]\033[0m"
        fi
    fi
}

# Launch threads to scan ports in parallel
for port in $(seq 1 65535); do
    # Limit number of threads to 10
    while [ $(jobs | wc -l) -ge 10 ]; do
        sleep 0.1
    done
    scan_port "$port" &
done

# Wait for all threads to finish
wait

if [ -n "$open_ports" ]; then
    echo -e "\n\nOpen ports found:"
    echo "$open_ports"
else
    echo -e "\n\nNo open ports found."
fi
