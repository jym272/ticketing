#!/usr/bin/env bash

set -eou pipefail

source "$(dirname "$0")"/exports.sh
cd "$PARENT_DIRECTORY"

URL="${URL:-https://ticketing.dev}"
THREADS="${THREADS:-2}"
JOBS_PER_THREAD="${JOBS_PER_THREAD:-10}"

UID_GID="$(id -u):$(id -g)"
BASE_URL="$URL/api/tickets"

export BASE_URL
export THREADS
export JOBS_PER_THREAD
export UID_GID

docker compose run -it --rm test_apis