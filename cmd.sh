#!/usr/bin/env bash


# ticketing.dev/api/users/signup  POST {email: 'jym272', password: '12345678Aa'}
curl ticketing.dev/api/users/signup -X POST -H "Content-Type: application/json" -d '{"email": "jym272@gmail.com", "password": "12345678Aa"}'