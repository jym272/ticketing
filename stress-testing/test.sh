#!/usr/bin/env bash

set -eou pipefail

declare  -A ids

n=10

function random_id() {
    echo $(shuf -i 1000-100000 -n 1)
}
function random_unique_id() {
    local id
    while [[ -z ${id+x} || ${ids[$id]+_} ]]; do
        id=$(random_id)
    done
    echo $id
}

for i in $(seq 1 $n); do
  iteration=$((i))
  unique_id=$(random_unique_id)
  ids[$unique_id]=_
  echo "Iteration $iteration, unique_id $unique_id"
done
echo "Initial map:"
for k in "${!ids[@]}"; do
  echo "$k => ${ids[$k]}"
done

function write_ids_to_csv() {
    local csv_file="ids.csv"
    echo "id" > "$csv_file"
    for id in "${!ids[@]}"; do
        echo "$id" >> "$csv_file"
    done
}

write_ids_to_csv