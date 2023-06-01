## Testing Tickets API and Orders API

**Contents**
1. [Ingress](#ingress)
2. [Cookie](#cookie)
3. [Delete databases](#delete-databases)
4. [Execute the script](#execute-the-script)
5. [Check the results](#check-the-results)
6. [Clean](#clean)
---

- The goal of the script is to test the performance and correctness of the APIs, and how they 
  behave under heavy load.
- The Order Service listens to the `events` **create** and **update** Ticket.
---
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

### Delete databases
Prepare the databases por testing environments, to delete the _Ticket Table_ from 
**Orders API** and **Tickets API**:
```bash
make delete_db
```


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

### Check the results
Once the test has finished, two files are created, `create_errors.test.csv` and 
`update_errors.test.csv`, the errors correspond to the creation and update of the tickets in the 
**Tickets API**, to analyze the results of these files, you can use the following commands:
```bash
make check_errors_create
make check_errors_update
``` 
If no **API** _errors_ are found, you can also check the `results` of the versioning of the tickets 
in the **APIs**, all versions must be version **3** in the _Ticket Table_ in the **Orders API** and in 
the **Tickets API**.
```bash
make results
make get_results
``` 

### Clean
Delete the files related to the test.
```bash
make clean
```
