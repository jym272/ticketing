


## Using SealedSecrets for secret management

A Kubernetes controller and tool for one-way encrypted Secrets. 
- https://github.com/bitnami-labs/sealed-secrets
- https://artifacthub.io/packages/helm/bitnami-labs/sealed-secrets

Installation with helm charts
```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets && helm repo update
# The helm chart by default installs the controller with the name: sealed-secrets
# --fullnameOverride: sealed-secrets-controller
helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
# Install cli, kubeseal assumes by default:
# - controller-name: sealed-secrets-controller
# - namespace: kube-system
brew install kubeseal
```
1. Install the client-side tool (kubeseal) as explained in the docs below:

   https://github.com/bitnami-labs/sealed-secrets#installation-from-source

2. Create a sealed secret file running the command below:

   kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o [json|yaml] | \
   kubeseal \
   --controller-name=sealed-secrets-controller \
   --controller-namespace=kube-system \
   --format yaml > mysealedsecret.[json|yaml]

The file mysealedsecret.[json|yaml] is a commitable file.

If you would rather not need access to the cluster to generate the sealed secret you can run:

    kubeseal \
      --controller-name=sealed-secrets-controller \
      --controller-namespace=kube-system \
      --fetch-cert > mycert.pem

to retrieve the public cert used for encryption and store it locally. You can then run 'kubeseal --cert mycert.pem' instead to use the local cert e.g.

    kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o [json|yaml] | \
    kubeseal \
      --controller-name=sealed-secrets-controller \
      --controller-namespace=kube-system \
      --format [json|yaml] --cert mycert.pem > mysealedsecret.[json|yaml]

3. Apply the sealed secret

   kubectl create -f mysealedsecret.[json|yaml]

Running 'kubectl get secret secret-name -o [json|yaml]' will show the decrypted secret that was generated from the sealed secret.

Both the SealedSecret and generated Secret must have the same name and namespace.


// The SealedSecret can be decrypted only by the controller running in the target cluster and nobody else (not even the original author) is able to obtain the original Secret from the SealedSecret.

for local use kubeseal -> for git use env vars

use sealed secrets for all - > document
docleumt dashboard

# check if sealed secrets is installed
kubectl get pods -n kube-system | grep sealed
# check if sealed secrets is installed with helm
helm list -n kube-system | grep sealed
