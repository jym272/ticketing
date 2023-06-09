#!/usr/bin/env bash

set -eou pipefail

# it needs PORT-FORWARDING
export NATS_URL="nats://localhost:4222"
# declare a map of unique ids
declare -A ids

n=10

function random_id() {
#    local min=${1:-0}   # default minimum value is 0
#    local max=${2:-100} # default maximum value is 100
    echo "$(shuf -i 1000-100000 -n 1)"
}
function random_unique_id() {
    local id
    while [[ -z ${id+x} || ${ids[$id]+_} ]]; do
        id=$(random_id)
    done
    echo "$id"
}
dir=$(dirname "$0")
bash "$dir/create_json.sh"

cd "$dir"
for i in $(seq 1 $n); do
  iteration=$((i))
  unique_id=$(random_unique_id)
  ids[$unique_id]=_
  echo "Iteration $iteration, unique_id $unique_id"
  sed -i -E "s/\"id\": [0-9]+/\"id\": $unique_id/" file0.test.json
  sed -i -E "s/\"id\": [0-9]+/\"id\": $unique_id/" file1.test.json
  sed -i -E "s/\"id\": [0-9]+/\"id\": $unique_id/" file2.test.json
  sed -i -E "s/\"id\": [0-9]+/\"id\": $unique_id/" file3.test.json

  nats pub tickets.created "$(jq -r '@json' file0.test.json)"

  nats pub tickets.updated "$(jq -r '@json' file1.test.json)"

  nats pub tickets.updated "$(jq -r '@json' file2.test.json)"

  nats pub tickets.updated "$(jq -r '@json' file3.test.json)"

done

function write_ids_to_csv() {
    local csv_file="ids.test.csv"
    echo "id" > "$csv_file"
    for id in "${!ids[@]}"; do
        echo "$id" >> "$csv_file"
    done
}

write_ids_to_csv

rm -f ./*.test.json