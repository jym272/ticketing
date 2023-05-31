#!/usr/bin/env bash

set -eou pipefail
source "$(dirname "$0")"/functions.sh

declare dbs=(orders tickets)

function print_results() {
  local pgpool_replica=$2
  local db=$1
  local count is_empty
  local version_0 version_1 version_2

  echo -e  "\e[33m|------ db-$db   'ticket' Table ------|\e[0m"
  is_empty=$(kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -d '$db' -h /opt/bitnami/pgpool/tmp/ -P pager=off -q -t -c 'SELECT COUNT(*) FROM ticket;'" | tr -d '[:space:]')
  if [[ "$is_empty" -eq 0 ]]; then
    echo -e  "\e[32mTable is empty\e[0m"
    return
  fi
  count=$(kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -d '$db' -h /opt/bitnami/pgpool/tmp/ -P pager=off -q -t -c 'SELECT COUNT(*) FROM ticket WHERE version <> 3;'" | tr -d '[:space:]')

  if [[ "$count" -eq 0 ]]; then
    echo -e  "\e[32mAll tickets with version 3\e[0m"
  else
    version_0=$(kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -d '$db' -h /opt/bitnami/pgpool/tmp/ -P pager=off -q -t -c 'SELECT id FROM ticket WHERE version = 0 ORDER BY id;'" | tr -d '\r' | tr '\n' ' ' | sed  's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -n "$(echo "$version_0" | tr -d '[:space:]')" ]; then
      echo -e "\e[32mTickets ids with version 0: \e[0m $version_0"
    fi
    version_1=$(kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -d '$db' -h /opt/bitnami/pgpool/tmp/ -P pager=off -q -t -c 'SELECT id FROM ticket WHERE version = 1 ORDER BY id;'" | tr -d '\r' | tr '\n' ' ' | sed  's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -n "$(echo "$version_1" | tr -d '[:space:]')" ]; then
      echo -e "\e[32mTickets ids with version 1: \e[0m $version_1"
    fi
    version_2=$(kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -d '$db' -h /opt/bitnami/pgpool/tmp/ -P pager=off -q -t -c 'SELECT id FROM ticket WHERE version = 2 ORDER BY id;'" | tr -d '\r' | tr '\n' ' ' | sed  's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -n "$(echo "$version_2" | tr -d '[:space:]')" ]; then
      echo -e "\e[32mTickets ids with version 2: \e[0m $version_2"
    fi
  fi
}

for db in "${dbs[@]}"; do
  pgpool_replica=$(get_pgpool_replica "$db")

  if [[ -z "$pgpool_replica" ]]; then
    echo -e "\e[31mNo pgpool replica found for $db\e[0m"
    exit 1
  fi

  print_results "$db" "$pgpool_replica"
done
