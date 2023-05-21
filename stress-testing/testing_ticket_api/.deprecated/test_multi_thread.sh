#!/usr/bin/env bash

set -eou pipefail

if [ ! -f cookie ]; then
    echo "cookie file not found"
    exit 1
fi
declare id_new_ticket
declare -A errors_updating_tks
declare -A errors_creating_tks
declare url
declare threads

url="https://ticketing.dev/api/tickets"
#url="https://www.jym272.online/api/tickets"
n=10
threads=20
# Total processes = threads * n

function update_tk() {
    local title=$1
    local price=$2
    local id=$3
    local status
    status=$(curl -s -b cookie -k "$url/$id" -X PUT -H "Content-Type: application/json" -d '{"title": "'$title'", "price": "'$price'"}' | jq -r '.message')
    echo "$status"
}

function create_thread() {
  local init_=$1
  local init=$((init_+1))
  local end=$2
  local thread=$3

  echo -e "\e[32mTHREAD $thread with jobs\t$init - $end\tstarted\e[0m"
  for i in $(seq "$init" "$end"); do
    local iteration=$((i))
    id_new_ticket=$(curl -s -b cookie -k "$url" -X POST -H "Content-Type: application/json" -d '{"title": "apple", "price": "69.69"}' | jq -r '.ticket.id')
    if [ -z "$id_new_ticket" ]; then
        errors_creating_tks[$iteration]=_
        continue
    fi
    errors_updating_tks[$id_new_ticket]=0
    local update_status
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
    echo -e "\e[33mTHREAD $thread\e[0m - iteration $iteration done"
  done

}

for i in $(seq 0 $((threads-1))); do
  thread=$((i))
  init=$((i*n))
  end=$((init+n))
  create_thread "$init" "$end" "$((thread+1))" &

  echo -e "\e[1;33m ----- THREAD $((thread+1)) CREATED -----\e[0m"
done

# wait for all threads to finish
wait

function create_csv_files {
    local update_errors="update_errors.test.csv"
    local create_errors="create_errors.test.csv"
    echo "id,errors" > "$update_errors"
    for key in "${!errors_updating_tks[@]}"; do
        echo "$key,${errors_updating_tks[$key]}" >> "$update_errors"
    done

    echo "iteration" > "$create_errors"
    for key in "${!errors_creating_tks[@]}"; do
        echo "$key" >> "$create_errors"
    done
}

create_csv_files