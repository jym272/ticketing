## Using SealedSecrets for secret management

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
The secrets created can only be decrypted by the controller `sealed-secrets-controller` **of a 
particular cluster !IMPORTANT**, thereby, is safe to store such secrets in a public repository.

If is a known context: **minikube**, **multinodes** the file is created in the folder
`k8s/overlay/<context>`

The scripts take the arguments:
- **name**: name of the secret, `secretKeyRef.name`
- **key=value**: key value pairs of the secret


Examples:
```shell
bash scripts/create-sealed-secret.sh sealed-secret-postgres POSTGRES_PASSWORD=my_secure_pass POSTGRES_USER=admin
```
