#!/usr/bin/env bash

declare port
port=8080

set -eou pipefail
pod=$(kubectl get pods -n monitoring -l app=prometheus-server -o jsonpath="{.items[0].metadata.name}")
echo "http://localhost:${port}"
kubectl -n monitoring port-forward "$pod" "$port":9090