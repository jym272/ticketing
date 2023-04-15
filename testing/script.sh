#!/usr/bin/env bash

set -eou pipefail


# create tk
id_new_ticket=$(curl -s -b cookie -k https://ticketing.dev/api/tickets -X POST -H "Content-Type: application/json" -d '{"title": "apple", "price": "69.69"}' | jq -r '.ticket.id')
if [ -z "$id_new_ticket" ]; then
    echo "error creating ticket"
    exit 1
fi
# timeout until ticket is created in order-api 'cause of listener of ticket-created event
sleep 0.2
# create order
id_new_order=$(curl -s -b cookie -k https://ticketing.dev/api/orders -X POST -H "Content-Type: application/json" -d '{"ticketId": "'$id_new_ticket'"}' | jq -r '.order.id')
if [ -z "$id_new_order" ]; then
    echo "error creating order"
    exit 1
fi
