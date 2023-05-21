#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIRECTORY="${DIR%/*}"
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