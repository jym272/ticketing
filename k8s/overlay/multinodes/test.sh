#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


new_value='12.21.21.2'

dir_of_kustomization_file="$DIR/storage/kustomization.yml"

new_value="199.168.122.1"

sed -i "s/value: .*/value: $new_value/g" "$dir_of_kustomization_file"

