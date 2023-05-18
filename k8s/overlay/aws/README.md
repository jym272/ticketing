# AWS
**Contents**
1. [Infrastructure in AWS with terraform](#infrastructure-in-aws-with-terraform)
   1. [Create cluster](#create-cluster)
   2. [Install nginx and cert-manager](#install-nginx-and-cert-manager)
   3. [Manage DNS Records](#manage-dns-records)
   4. [Create Sealed Secrets](#create-sealed-secrets)
   5. [Securing the Ingress Using Cert-Manager](#securing-the-ingress-using-cert-manager)
   6. [Volumes](#volumes)
2. [Resources](#resources)
   1. [Create](#create)
   2. [Delete](#delete)

---
## Infrastructure in AWS with terraform
### Create cluster
The infrastructure is created using terraform, the cluster is created using the module `terraform-aws-eks`.
```bash
terraform get 
terraform init
terraform plan
terraform apply -auto-approve
```
Add context to kubectl:
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Install nginx and cert-manager

To install the Nginx Ingress Controller to your cluster,
you'll first need to add its repository to Helm by running:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
Update your system to let Helm know what it contains:
```bash
helm repo update
```
Finally, run the following command to install the Nginx ingress:
```bash
helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
```
Run this command to watch the Load Balancer become available, `EXTERNAL-IP` must appear:
```bash
kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller
```
### Manage DNS Records
Using Route 53 with a host zone already created, add the CNAME Records for the subdomains, the 
value is the EXTERNAL-IP of the Load Balancer.

![image info](./.assets/subdomains.png)

The domain is administrated by Namecheap, add the CNAME Records for the subdomains also.

![image info](./.assets/namecheap.png)

Wait for the subdomains to be available. [check propagation of domains](https://www.whatsmydns.net/#CNAME/)

### Create Sealed Secrets
For secrets management `sealed-secrets` is used.
Follow the
[instructions.](../../../scripts/README.md#using-sealedsecrets-for-secret-management)

### Securing the Ingress Using Cert-Manager
Deploy infrastructure first:
```bash
kubectl apply -k k8s/overlay/aws/
```  
Comment the line `cert-manager.io/cluster-issuer: letsencrypt-prod` in `ingress.yaml` and apply it.
```bash
kubectll apply -f k8s/overlay/aws/ingress.yaml
```

[Cert Manager nginx doc](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/)
Before installing Cert-Manager to your cluster via Helm, you'll create a namespace for it:
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
kubectl apply -f k8s/overlay/aws/production_issuer.yaml
```
Finally, uncomment the `cert-manager.io/cluster-issuer: letsencrypt-prod` line in `ingress.yaml`
and apply it.
```bash
kubectl apply -f k8s/overlay/aws/ingress.yaml
```
Once the `ingress.yaml` file is updated, You’ll need to wait a few minutes for the Let’s Encrypt 
servers to issue a certificate for your domains. In the meantime, you can track progress 
by inspecting the output of the following command:
```bash
kubectl describe certificate jym272-foundation-tls
# inspect the challenges
kubectl get challenges.acme.cert-manager.io -o wide
kubectl get certificate
```

Wait for **The certificate has been successfully issued** message. 
If it fails or take more than 10 minutes, review the `domains` and the ingress file, you can change
the name of `secretName`in ingress.

[More info and troubleshooting](https://cert-manager.io/docs/troubleshooting/acme/),

### Volumes
- [ebs_csi_addon](https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/)
   - [examples](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes)
  
---

## Resources
### Create
```bash
kubectl apply -k k8s/overlay/aws/
```
Uncomment `cert-manager.io/cluster-issuer: letsencrypt-prod` line only if you have a valid 
certificate.
```bash
kubectll apply -f k8s/overlay/aws/ingress.yaml
```
### Delete
**EBS Volumes** are created by the **StatefulSet**, these needs to be deleted manually.

```bash
kubectl delete -k k8s/overlay/aws/
kubectl delete -f k8s/overlay/aws/ingress.yaml
```
The `PVC's` are dynamically created by **StatefulSet**. Delete them manually
```bash
kubectl delete pvc auth-claim-db-auth-0 nats-claim-nats-0 orders-claim-db-orders-0 payments-claim-db-payments-0 tickets-claim-db-tickets-0 redis-claim-redis-0
```
If the `reclaimPolicy: Retain`policy is used in the **storage class**, the **PV's** are not 
deleted, 
you need to delete them manually also, otherwise the **EBS Volumes** are not deleted, even if 
the infrastructure is deleted with terraform destroy.
```bash
kubectl delete pv $(kubectl get pv | grep Released | awk '{print $1}')
```
When `nginx` is created a `LoadBalancer` is created, this also needs to be deleted manually.
```bash
helm uninstall nginx-ingress
```
