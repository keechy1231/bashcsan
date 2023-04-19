#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <ip> [common|all]"
    exit 1
fi

target="$1"
open_ports=""
scan_range="1-65535"

# List of commonly used ports
common_ports="20,21,22,23,25,53,67,68,69,80,88,110,123,135,139,137,138,139,143,145,161,162,179,389,443,445,464,465,514,515,587,593,631,636,993,995,1080,1194,1433,1434,1521,1701,1723,1812,1813,2222,2375,2376,3268,3269,3389,3899,4000,4001,4002,4444,4500,5432,5632,5900,5901,5984,6379,6443,7001,7002,7003,7004,7005,7006,7007,7008,7009,7010,7500,8000,8001,8002,8003,8004,8005,8006,8007,8008,8009,8010,8080,8081,8443,8888,9000,9043,9200,9300,9443,10000,11211,27017,27018,27019,28017,50000"

# Check if user wants to scan top 1000 ports
if [ "$2" = "common" ]; then
    scan_range=$(echo "$common_ports" | cut -d "," -f 1-1000 | tr "," "\n" | paste -sd ",")
fi

# Start scan
echo "Scanning ports on $target..."
for port in $(echo $scan_range | tr ',' ' '); do
    # Limit number of threads to 10
    while [ $(jobs | wc -l) -ge 10 ]; do
        sleep 0.1
    done
    (echo >/dev/tcp/$target/$port) >/dev/null 2>&1 && echo "$port/tcp open" &
done

# Wait for all threads to finish
wait

# Print results
if [ -n "$open_ports" ]; then
    echo -e "\n\nOpen ports found:"
    echo "$open_ports"
else
    echo -e "\n\nNo open ports found."
fi
