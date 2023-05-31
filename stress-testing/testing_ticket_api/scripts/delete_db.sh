#!/usr/bin/env bash

set -eou pipefail

source "$(dirname "$0")"/functions.sh

declare dbs=(orders tickets)

function delete_ticket_table() {
  local pgpool_replica=$2
  local db=$1
  kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -h /opt/bitnami/pgpool/tmp/ -d '$db' -t -q -c 'DELETE FROM \"ticket\";'"
}

for db in "${dbs[@]}"; do
  pgpool_replica=$(get_pgpool_replica "$db")
  if [[ -z "$pgpool_replica" ]]; then
    echo -e "\e[31mNo pgpool replica found for $db\e[0m"
    exit 1
  fi

  delete_ticket_table "$db" "$pgpool_replica"
  echo -e "\e[32m\"ticket\" table in $db db deleted\e[0m"
done