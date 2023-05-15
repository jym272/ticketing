#!/usr/bin/env bash

set -eou pipefail

declare pid

function cleanup {
    echo "Cleaning up..."
    kill "$pid"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start kubectl logs command in the background and capture the PID
kubectl logs -f -l api=frontend &
pid=$!

# Check if the process is still running every second
while true; do
    if ! kill -0 $pid; then
        echo "Process $pid is not running. Restarting..."
        kubectl logs -f -l api=frontend &
        pid=$!
    fi
    sleep 1
done