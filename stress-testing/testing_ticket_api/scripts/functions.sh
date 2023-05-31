#!/usr/bin/env bash

set -eou pipefail


function get_pgpool_replica() {
  local app=$1
  local replica_array
  local replicas
  local pgpool_replica
  replicas=$(kubectl get pod -l app=pgpool-"$app" -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')

  # Split the pod names into an array
  IFS=' ' read -ra replica_array <<< "$replicas"

  if [[ "${#replica_array[@]}" -gt 0 ]]; then
    pgpool_replica="${replica_array[0]}"
    echo "$pgpool_replica"
  else
    echo ""
  fi
}
