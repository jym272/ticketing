
#### Create a cookie file
The cookie is directly relate to thw JWT_SECRET

```bash
curl -c cookie -k https://ticketing.dev/api/users/signup -X POST -H "Content-Type: application/json" -d '{"email": "jym272@gmail.com", "password": "1234567A8a"}'
```

#### Errors


```bash
# Get the error count
sort update_errors.csv | awk -F '[,]' '{print $2}' | uniq -c
```