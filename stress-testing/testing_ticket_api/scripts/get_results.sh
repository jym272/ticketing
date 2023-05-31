#!/usr/bin/env bash

set -eou pipefail
source "$(dirname "$0")"/exports.sh
source "$(dirname "$0")"/functions.sh

cd "$PARENT_DIRECTORY"

declare dbs=(orders tickets)

function create_results_file() {
  local pgpool_replica=$2
  local db=$1
  kubectl exec -it "$pgpool_replica" --quiet -- bash -ec "psql -U 'postgres' -h /opt/bitnami/pgpool/tmp/ -d '$db' -P pager=off -q -c 'SELECT
  id,
  MAX(CASE WHEN version = 0 THEN version ELSE NULL END) AS version_0,
  MAX(CASE WHEN version = 1 THEN version ELSE NULL END) AS version_1,
  MAX(CASE WHEN version = 2 THEN version ELSE NULL END) AS version_2,
  MAX(CASE WHEN version = 3 THEN version ELSE NULL END) AS version_3
FROM
  ticket
GROUP BY
  id
ORDER BY
  id;'" > "$db-db_ticket-table.txt"
}

for db in "${dbs[@]}"; do
  pgpool_replica=$(get_pgpool_replica "$db")
  if [[ -z "$pgpool_replica" ]]; then
    echo -e "\e[31mNo pgpool replica found for $db\e[0m"
    exit 1
  fi

  create_results_file "$db" "$pgpool_replica"
  echo -e "\e[32m\"$db-db_ticket-table.txt\" file created\e[0m"
done