#!/usr/bin/env bash
set -eou pipefail
# https://cloud.google.com/kubernetes-engine/docs/archive/using-container-image-digests-in-kubernetes-manifests#using_kustomize
declare -A options
declare tag option digest service cmd manifest_filename

tag="latest"
options=(["auth"]="ticketing-auth-api" ["expiration"]="ticketing-expiration-api" ["orders"]="ticketing-orders-api"
	["payments"]="ticketing-payments-api" ["tickets"]="ticketing-tickets-api" ["frontend"]="ticketing-frontend")

if [[ $# -ne 1 ]]; then
	echo -e "\e[1;31mInvalid number of arguments\e[0m"
	echo -e "\e[1;32mUsage: bash $0 [auth|expiration|orders|payments|tickets|frontend]\e[0m"
	exit 1
fi

function validate_key {
	local arg=$1
	local keys=("${!options[@]}")
	for key in "${keys[@]}"; do
		if [[ $key == "$arg" ]]; then
			return 0
		fi
	done
	return 1
}

if ! validate_key "$1"; then
	echo -e "\e[1;31mInvalid argument\e[0m"
	echo -e "\e[1;32mUsage: bash $0 [auth|expiration|orders|payments|tickets|frontend]\e[0m"
	exit 1
fi

service="$1"
option="${options[$service]}"
digest=$(curl -s "https://hub.docker.com/v2/repositories/jym272/$option/tags/$tag" | jq -r '.images[0].digest')
image="jym272/$option"

echo -e "\e[1;32mImage: $image\e[0m"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIRECTORY="${DIR%/*}"

yq-docker() {
	docker run --rm -i -v "$PARENT_DIRECTORY/k8s/base":/workdir mikefarah/yq "$@"
}

if command -v yq &>/dev/null; then
	cmd="yq"
	manifest_filename="$PARENT_DIRECTORY/k8s/base/kustomization.yml"
else
	cmd="yq-docker"
	manifest_filename="kustomization.yml"
fi

$cmd eval ".images[] |= select(.name == \"$image\").digest = \"$digest\"" -i "$manifest_filename"
echo -e "\e[1;32mDigest: $digest\e[0m"
