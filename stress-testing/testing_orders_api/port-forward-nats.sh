#!/usr/bin/env bash

set -eou pipefail
declare deploy=nats
declare -A ports=(["host"]=4222 ["container"]=4222)

declare container_name

find_container_using_deploy() {
  # retrieving only the first container name
  container_name=$(kubectl get pods -l app="$deploy" -o jsonpath="{.items[0].metadata.name}")
}

find_container_using_deploy
kubectl port-forward "$container_name" "${ports["host"]}:${ports["container"]}"
