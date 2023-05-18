# Ticketing Project

The **microservices project** consists of multiple services that communicate with each other using 
**NATS Streaming Server**.
Each service has its own **PostgreSQL** database. 
Additionally, the Expiration API utilizes **Redis** database for handling _expired payments_.

The choice of storage volumes depends on the overlay / environment used in the infrastructure 
deployment.

For local database management, **Adminer** is used as a tool. Adminer allows users to interact with 
and manage the databases in the project.
 
This project draws inspiration from the  [Microservices with Node JS and React](https://www.udemy.com/course/microservices-with-node-js-and-react/) course by Stephen Grider.
While the project is not an exact replica of the course material, it incorporates similar principles and concepts discussed in the course.

---
**Contents**
1. [Initial Setup](#initial-setup)
2. [Environments](#environments)
3. [Microservices](#microservices)
---
## Initial Setup
> To clone this project including its submodules updated to the latest revision use this command:
>```bash
>git clone --recurse-submodules --remote-submodules https://github.com/jym272/ticketing.git
>```
---
## Environments
The **application** utilizes _**kustomize**_, a configuration management tool, to handle different environments. 
The project consists of a `base` configuration that remains the same across all environments. 
However, the variations among environments are managed through the overlays folder.

Within each overlay, there is a `kustomization.yaml` file that specifies the base configuration. 
Additionally, the overlays apply specific _patches_ to modify and 'kustomize' the base configuration 
according to the requirements of each environment. 

This approach allows for easy management and customization of the application's configuration for 
different deployment scenarios.
For more advanced features of kustomize, you can refer to the 
[Advanced Kustomize Features](https://www.innoq.com/en/blog/advanced-kustomize-features/) article.

The different **environments/overlays** are:
>- #### [AWS](./k8s/overlay/aws/README.md)
>- #### [DigitalOcean](./k8s/overlay/digitalOcean/README.md)
>- #### [minikube](./k8s/overlay/minikube/README.md)
>- #### [skaffold](./k8s/overlay/skaffold/README.md)
---
## Microservices

In this microservices project, the communication between services is facilitated by **Nats 
Streaming Server**, 
which provides a messaging system. The **REST APIs** are primarily implemented using **Node.js**, 
except for the Expiration API, which is written in **Go**.

The client-side application is developed using the **Next.js** framework, which is a popular choice 
for building server-rendered React applications.

To handle networking and routing, a **Nginx Ingress Controller** is utilized. The 
[**Nginx Ingress Service**](./k8s/base/ingress/ingress.yaml) 
acts as an entry point for external traffic, manages load balancing, and handles 
routing requests to the appropriate services within the microservices architecture.
> ### Rest APIs
> - [auth-api](https://github.com/jym272/ticketing-auth)
> - [expiration-api](https://github.com/jym272/ticketing-expiration)
> - [orders-api](https://github.com/jym272/ticketing-orders)
> - [payments-api](https://github.com/jym272/ticketing-payments)
> - [tickets-api](https://github.com/jym272/ticketing-tickets)
> ### Common Library
> Used in all Api's, except `expiration-api`:
> - [common](https://github.com/jym272/ticketing-common)
> ### Client
> Frontend or client:
> - [client](https://github.com/jym272/ticketing-client)