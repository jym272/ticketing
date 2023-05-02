#!/bin/bash

previous_output=""

while true; do
    output=$(kubectl describe certificate hello-kubernetes-tls)

    if [[ "$output" != "$previous_output" ]]; then
        echo "$output"
        previous_output="$output"
    fi

    sleep 1
done
