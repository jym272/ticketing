#!/usr/bin/env bash

set -eou pipefail
source "$(dirname "$0")"/exports.sh
cd "$PARENT_DIRECTORY"

URL="${URL:-https://ticketing.dev}"
EMAIL="user_${RANDOM}@gmail.com"

curl -c cookie -k "$URL/api/users/signup" -X POST -H "Content-Type: application/json" -d "{\"email\": \"$EMAIL\", \"password\": \"1234567A8a\"}"
