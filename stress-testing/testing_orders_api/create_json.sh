#!/usr/bin/env bash

set -eou pipefail

dir=$(dirname "$0")
cd "$dir"

cat <<EOF > file0.test.json
{
  "tickets.created": {
    "id": 5675,
    "title": "New ticket",
    "price": 69,
    "version": 0
  }
}
EOF
cat <<EOF > file1.test.json
{
  "tickets.updated": {
    "id": 5675,
    "title": "New ticket",
    "price": 100,
    "version": 1
  }
}
EOF
cat <<EOF > file2.test.json
{
  "tickets.updated": {
    "id": 5675,
    "title": "New ticket",
    "price": 200,
    "version": 2
  }
}
EOF
cat <<EOF > file3.test.json
{
  "tickets.updated": {
    "id": 5675,
    "title": "New ticket",
    "price": 300,
    "version": 3
  }
}
EOF