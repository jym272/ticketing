#!/usr/bin/env bash

set -eou pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIRECTORY="${DIR%/*}"
cd "$PARENT_DIRECTORY"

URL="${URL:-https://ticketing.dev}"
EMAIL="user_${RANDOM}@gmail.com"

curl -c cookie -k "$URL/api/users/signup" -X POST -H "Content-Type: application/json" -d "{\"email\": \"$EMAIL\", \"password\": \"1234567A8a\"}"
