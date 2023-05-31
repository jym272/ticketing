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

**i.e.** `192.168.39.128  ticketing.dev`    

### Cookie
The **scripts** needs a _cookie_ from a **valid user**.
> Use `makefile` to generate the cookie, the **URL** used by default is `https://ticketing.dev`,
> but you can change it with the environment variable **URL**.
>```bash
>make cookie
>```
>With a **custom url**:
>```bash
>URL=https://my-url.com make cookie
>```
>You can also `export` the **URL** and run the command without the **URL** argument:
>```bash
>export URL=https://my-url.com 
>make cookie
>```

### Execute the script
>The default environment variables are:
>- `URL=https://ticketing.dev`
>- `THREADS=2`
>- `JOBS_PER_THREAD=10`
>```bash
>make test
>```
>With custom environment variables:
>```bash
>URL=https://my-url.com THREADS=5 JOBS_PER_THREAD=20 make test
>```

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
