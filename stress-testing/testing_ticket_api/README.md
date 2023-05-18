## Testing Tickets API and Orders API

**Contents**
1. [Init](#init)
   1. [Ingress](#ingress)
   2. [Cookie](#cookie)
   3. [Execute the script](#execute-the-script)
2. [Check the results](#check-the-results)
   1. [Errors](#errors)
   2. [Clean](#clean)
---

- The goal of the script is to test the performance and correctness of the APIs.
- The Order Service listens to the `events` **create** and **update** Ticket.
---
## Init
### Ingress
Make sure that the ingress service is enabled and correctly configured.

```bash
minikube addons enable ingress -p [multinodes|minikube]
```
Add the `minikube ip -p [multinodes|minikube]` to `/etc/hosts`.

i.e. `192.168.39.128  ticketing.dev`    

### Cookie
- The cookie is directly relate to the **JWT_SECRET**.
- The **script** needs a cookie from a **valid user**, generate a cookie with the following command:

```bash
cd stress-testing/testing_ticket_api
curl -c cookie -k https://ticketing.dev/api/users/signup -X POST -H "Content-Type: application/json" -d '{"email": "user@gmail.com", "password": "1234567A8a"}'
```

### Execute the script
```bash
bash script.sh
```
---

## Check the results
```bash
db_tickets=$(kubectl get pods -l db=tickets -o jsonpath="{.items[0].metadata.name}")
db_orders=$(kubectl get pods -l db=orders -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it "$db_tickets" -- psql -U jorge -d tickets -t -c 'SELECT COUNT(*) FROM "ticket" WHERE "version" = 3;' -q
    #1000
kubectl exec -it "$db_tickets" -- psql -U jorge -d tickets -t -c 'SELECT COUNT(*) FROM "ticket" WHERE "version" <> 3;' -q
    #0
kubectl exec -it "$db_orders" -- psql -U jorge -d orders -t -c 'SELECT COUNT(*) FROM "ticket" WHERE "version" = 3;' -q
    #1000
kubectl exec -it "$db_orders" -- psql -U jorge -d orders -t -c 'SELECT COUNT(*) FROM "ticket" WHERE "version" <> 3;' -q
    #0
``` 

### Errors

The `create_errors.test.csv` is created, if any creation of a ticket results in an error, the 
iteration number is added to the file.

The `update_errors.test.csv` is created, it has two columns, the ticketId and the number of 
errors if the update fails.


```bash
# Get the error count
sort update_errors.test.csv | awk -F '[,]' '{print $2}' | uniq -c
  # 1000 0 -> 1000 tickets updated without errors
```

### Clean

Clean the db's before and after run the test:
```bash
db_tickets=$(kubectl get pods -l db=tickets -o jsonpath="{.items[0].metadata.name}")
db_orders=$(kubectl get pods -l db=orders -o jsonpath="{.items[0].metadata.name}")

kubectl exec -it "$db_tickets" -- psql -U jorge -d tickets -t -c 'DELETE FROM "ticket";' -q
kubectl exec -it "$db_orders" -- psql -U jorge -d orders -t -c 'DELETE FROM "ticket";' -q
```
