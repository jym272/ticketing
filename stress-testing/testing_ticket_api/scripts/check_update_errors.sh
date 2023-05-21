#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIRECTORY="${DIR%/*}"
cd "$PARENT_DIRECTORY"

num_errors=$(awk -F, 'NR > 1 && $1+0 == $1 && $2 != 0 {count += $2} END {print count}' update_errors.test.csv)

if [ -z "$num_errors" ]; then
    echo -e "\e[32mThere are no errors updating the tickets\e[0m"
    exit 0
else
    echo -e "\e[31mThere are $num_errors errors updating the tickets\e[0m"
    awk -F, -v yellow="\033[33m" -v red="\033[31m" -v reset="\033[0m" 'NR > 1 && $1+0 == $1 && $2 != 0 {
        printf "Ticket with %sID %s%s has %s%s error%s%s\n", yellow, $1, reset, red, $2, ($2 > 1 ? "s" : ""), reset
    }' update_errors.test.csv
    exit 1
fi
