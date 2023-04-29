#!/usr/bin/env bash


minikube_gateway_address=$(minikube ssh -p multinodes -- ip route | awk '/default/ { print $3 }' | tr -d '[:space:]') # '/r' is carriage return


# dir of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
#PARENT_DIRECTORY="${DIR%/*}"
echo "$minikube_gateway_address"

find "$DIR/storage" -type f -name "*.yml" -exec sed -i "s/server: .*/server: $minikube_gateway_address/g" {} \;
find "$DIR/storage" -type f -name "*.yaml" -exec sed -i "s/server: .*/server: $minikube_gateway_address/g" {} \;

