#!/usr/bin/env bash

set -eou pipefail

if [ ! -f cookie ]; then
    echo "cookie file not found"
    exit 1
fi
declare id_new_ticket
declare -A errors_updating_tks
declare -A errors_creating_tks

n=10000
function update_tk() {
    local title=$1
    local price=$2
    local id=$3
    local status
    status=$(curl -s -b cookie -k https://ticketing.dev/api/tickets/$id -X PUT -H "Content-Type: application/json" -d '{"title": "'$title'", "price": "'$price'"}' | jq -r '.message')
    echo "$status"
}

for i in $(seq 1 $n); do
  iteration=$((i))
  id_new_ticket=$(curl -s -b cookie -k https://ticketing.dev/api/tickets -X POST -H "Content-Type: application/json" -d '{"title": "apple", "price": "69.69"}' | jq -r '.ticket.id')
  if [ -z "$id_new_ticket" ]; then
      errors_creating_tks[$iteration]=_
  fi
  errors_updating_tks[$id_new_ticket]=0

  update_status=$(update_tk "pineapple" "100.11" "$id_new_ticket")
  if [ "$update_status" != "Ticket updated." ]; then
      errors_updating_tks[$id_new_ticket]=$((errors_updating_tks[$id_new_ticket]+1))
  fi

  update_status=$(update_tk "grass" "200.22" "$id_new_ticket")
  if [ "$update_status" != "Ticket updated." ]; then
      errors_updating_tks[$id_new_ticket]=$((errors_updating_tks[$id_new_ticket]+1))
  fi
  update_status=$(update_tk "weed" "300.33" "$id_new_ticket")
  if [ "$update_status" != "Ticket updated." ]; then
      errors_updating_tks[$id_new_ticket]=$((errors_updating_tks[$id_new_ticket]+1))
  fi
  echo "iteration $iteration done"
done

function create_csv_files {
    echo "id,errors" > update_errors.csv
    for key in "${!errors_updating_tks[@]}"; do
        echo "$key,${errors_updating_tks[$key]}" >> update_errors.csv
    done

    echo "iteration" > create_errors.csv
    for key in "${!errors_creating_tks[@]}"; do
        echo "$key" >> create_errors.csv
    done
}

create_csv_files