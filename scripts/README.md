**Contents**
1. [Using SealedSecrets for secret management](#using-sealedsecrets-for-secret-management)
    1. [Installation of the controller with helm charts](#installation-of-the-controller-with-helm-charts)
    2. [Installation of cli kubeseal](#installation-of-cli-kubeseal)
    3. [Creation of secrets](#creation-of-secrets)


## Using SealedSecrets for secret management
**IMPORTANT**: The secrets created can only be decrypted by the controller 
`sealed-secrets-controller` of a particular cluster, thereby, is safe to store such 
secrets in a public repository and if the cluster is deleted the secrets must be **generated 
again.**


`sealed-secrets` is a Kubernetes controller and tool for one-way encrypted Secrets. 
- https://github.com/bitnami-labs/sealed-secrets
- https://artifacthub.io/packages/helm/bitnami-labs/sealed-secrets

### Installation of the controller with helm charts
```shell
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets && helm repo update
```
The helm chart by default installs the controller with the name: `sealed-secrets`, to override 
this behavior the option `--fullnameOverride: sealed-secrets-controller` is used.
```shell
helm install sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller sealed-secrets/sealed-secrets
```
### Installation of cli kubeseal
The cli tool `kubeseal` assumes by default the following values:
- **--controller-name**:  `sealed-secrets-controller`
- **--controller-namespace**: `kube-system`
```shell
brew install kubeseal
```
### Creation of secrets

If is a known context: **minikube**, **multinodes**, **aws**(_arn:aws:eks:*_), **digitalOcean**
(_do-*_) 
the file is created in 
the folder
`k8s/overlay/<context>`

The scripts take the arguments:
- **name**: name of the secret, `secretKeyRef.name`
- **key=value**: key value pairs of the secret


The secrets needed are:
- **Postgres Secrets**
   ```shell
   bash scripts/create-sealed-secret.sh sealed-secret-postgres POSTGRES_PASSWORD=my_secure_pass POSTGRES_USER=admin
   ```
- **Stripe secrets**
   ```shell
   bash scripts/create-sealed-secret.sh sealed-secret-stripe STRIPE_SECRET_KEY=sk_test_D23d STRIPE_PUBLISHABLE_KEY=pk_test_51Kqwdqwd
   ```
- **Auth secrets**
To generate secure secrets use:
   ```shell
   openssl rand -base64 32
   openssl rand -hex 32
   ```
   ```shell
   bash scripts/create-sealed-secret.sh sealed-secret-auth JWT_SECRET=my_secure_secret PASSWORD_PEPPER=my_secure_pepper
   ```
