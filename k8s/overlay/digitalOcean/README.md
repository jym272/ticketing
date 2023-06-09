# Digital Ocean
**Contents**
1. [Create Infrastructure of Digital Ocean](#create-infrastructure-of-digital-ocean)
   1. [Create a Cluster](#create-a-cluster)
   2. [Install nginx and cert-manager](#install-nginx-and-cert-manager)
   3. [Manage DNS Records](#manage-dns-records)
   4. [Create Sealed Secrets](#create-sealed-secrets)
   5. [Install metrics-server](#install-metrics-server)
   6. [Securing the Ingress Using Cert-Manager](#securing-the-ingress-using-cert-manager)
   7. [Volumes](#volumes)
2. [Resources](#resources)
   1. [Create](#create)
   2. [Delete](#delete)
---
## Create Infrastructure of Digital Ocean
### Create a Cluster
- Create a cluster- > use the [console](https://cloud.digitalocean.com/login), default options are 
  fine, only select scale type `Autoscale`.
- The **context** is added in `kubectl` config with the command:
    ```bash
  doctl kubernetes cluster kubeconfig save e53a7675-fc4c-48de-ac38-a3e99adbfXXX
   ```
### Install nginx and cert-manager
_Based on [walkthrough](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm)_



To install the **Nginx Ingress Controller** to your cluster, you’ll first need to add its 
repository to Helm by running:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update
```
Run the following command to install the **Nginx Ingress**:
```bash
helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
```
Run this command to watch the **Load Balancer** become available, `EXTERNAL-IP` must appear:
```bash
kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller
```
### Manage DNS Records
Add a **domain** in the `Networking` tab in Digital Ocean console, then, route the **hostname** to 
the lb.

![image info](./.assets/manage_dns_records_root.png)

Create some **subdomains**.

![image info](./.assets/manage_dns_records_subdomain.png)

Wait for the **subdomains** to be available. [Check propagation of domains](https://www.whatsmydns.net/#CNAME/)

### Create Sealed Secrets
For secrets management `sealed-secrets` is used.
Follow the
**[instructions.](../../../scripts/README.md#using-sealedsecrets-for-secret-management)**

### Install metrics-server
You’ll start by adding the `metrics-server` repository to your helm package lists. 
You can use helm repo add:
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server && helm repo update metrics-server
```
Install the chart:
```bash
helm upgrade --install metrics-server metrics-server/metrics-server --namespace kube-system
```

### Securing the Ingress Using Cert-Manager
First, deploy the infrastructure for **cert-manager**:
```bash
kubectl apply -k k8s/overlay/digitalOcean/
```  
Comment the line `cert-manager.io/cluster-issuer: letsencrypt-prod` in `ingress.yaml` and apply it.
```bash
kubectl apply -f k8s/overlay/digitalOcean/ingress.yaml
```

[Cert Manager nginx doc](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/)
Before installing Cert-Manager to your cluster via Helm, you’ll create a namespace for it:
```bash
kubectl create namespace cert-manager
```
You'll need to add the Jetstack Helm repository to Helm, which hosts the Cert-Manager chart. To do this, run the following command:
```bash
helm repo add jetstack https://charts.jetstack.io && helm repo update
```
Finally, install Cert-Manager into the cert-manager namespace by running the following command, 
use [last version](https://artifacthub.io/packages/helm/cert-manager/cert-manager)
```bash
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.11.1 --set installCRDs=true
```
In order to begin issuing certificates,
you will need to set up a `ClusterIssuer`. 
[documentation](https://cert-manager.io/docs/configuration/)

```yaml
# production_issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # Email address used for ACME registration
    email: jym272@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Name of a secret used to store the ACME account private key
      name: letsencrypt-prod-private-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
      - http01:
          ingress:
            class: nginx
```
Roll it out with `kubectl`:
```bash
kubectl apply -f k8s/overlay/digitalOcean/production_issuer.yaml
```
Finally, uncomment the `cert-manager.io/cluster-issuer: letsencrypt-prod` line in `ingress.yaml`
and apply it.
```bash
kubectl apply -f k8s/overlay/digitalOcean/ingress.yaml
```
Once the `ingress.yaml` file is updated, You’ll need to wait a few minutes for the Let’s Encrypt 
servers to issue a certificate for your domains. In the meantime, you can track progress 
by inspecting the output of the following command:
```bash
# The secretName must be different for every Ingress you create.
# in ingress.yaml -> secretName: jym272-online-tls-2

kubectl describe certificate jym272-online-tls-2
```
Wait for **The certificate has been successfully issued** message.

If it fails or take more than 10 minutes, review the `domains` and the ingress file, you can change
the name of `secretName`in ingress.
```bash
# inspect the challenges
kubectl get challenges.acme.cert-manager.io -o wide
kubectl get certificate
```

[More info and troubleshooting](https://cert-manager.io/docs/troubleshooting/acme/),

### Volumes
Storage classes available: `kubectl get storageclasses.storage.k8s.io`.

The `storage-class` used is `do-block-storage` with provisioner `dobs.csi.digitalocean.com`, the 
Reclaim Policy is `Delete`, the volumes are deleted when the `pvc` is deleted. To mantain the data
when the `pvc` is deleted, use `do-block-storage-retain` storage class instead.

For information about volumes in Digital Ocean, follow the [tutorial](./tutorials/README.md).

---
## Resources
### Create
```bash
kubectl apply -k k8s/overlay/digitalOcean/  
# uncomment cert-manager.io/cluster-issuer: letsencrypt-prod line only if you have a valid certificate
kubectll apply -f k8s/overlay/digitalOcean/ingress.yaml
```
### Delete
```bash
kubectl delete -k k8s/overlay/digitalOcean/
kubectl delete -f k8s/overlay/digitalOcean/ingress.yaml
```

The `PVCs` are dynamically created by **StatefulSet**, so you need to delete them manually.
The **Volumes** are deleted if the storage class used has the `RECLAIMPOLICY` set to `Delete`
```bash
kubectl delete pvc --all
```
Delete the `LoadBalancer` created by `nginx-ingress`:
```bash
helm uninstall nginx-ingress
```
