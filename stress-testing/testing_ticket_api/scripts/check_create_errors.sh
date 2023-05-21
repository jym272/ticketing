#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIRECTORY="${DIR%/*}"
cd "$PARENT_DIRECTORY"

errors_accumulator=$(awk 'NR>1 {print $1}' create_errors.test.csv | sort -u | tr '\n' ' ')

if [ -z "$errors_accumulator" ]; then
    echo -e "\e[32mThere are no errors creating the tickets\e[0m"
    exit 0
else
    echo -e "\e[31mThere are errors in the iterations: \e[0m\e[33m\e[1m$errors_accumulator\e[0m"
    exit 1
fi