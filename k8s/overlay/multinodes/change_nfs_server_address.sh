#!/usr/bin/env bash

set -eou pipefail

minikube status -p multinodes >/dev/null 2>&1 || {
  echo >&2 "minikube multinodes is not running.  Aborting."
  exit 1
}

minikube_gateway_address=$(minikube ssh -p multinodes -- ip route | awk '/default/ { print $3 }' | tr -d '[:space:]') # '/r' is carriage return

#minikube_gateway_address=$(minikube ip -p multinodes | tr -d '[:space:]')
# dir of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#PARENT_DIRECTORY="${DIR%/*}"
echo "$minikube_gateway_address"

#find "$DIR/storage" -type f -name "*.yml" -exec sed -i "s/server: .*/server: $minikube_gateway_address/g" {} \;
#find "$DIR/storage" -type f -name "*.yaml" -exec sed -i "s/server: .*/server: $minikube_gateway_address/g" {} \;
dir_of_kustomization_file="$DIR/storage/kustomization.yml"

sed -i "s/value: .*/value: $minikube_gateway_address/g" "$dir_of_kustomization_file"
