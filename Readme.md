### Installation
- Install minikube
- Start minikube
- Init ingress in minikube with `minikube addons enable ingress`

### Minkube setup
```bash
minikube start --vm-driver kvm2
minikube addons enable ingress
```

### Skaffold dev
While in development, is not neccesary to have a image in docker hub, `skaffold` will build 
the image using the `dev.Dockerfile`.
Get the correct IP address by running `minikube ip` and replace the IP address in `/etc/hosts`.

```bash
# /etc/hosts
...
192.168.36.xxx posts.com
```
Run the following command to start the application.
```bash
skaffold dev --profile local
```


### Bypass the unsafe certificate
if chrome/mozilla does not allow you to access the site defined in `ingress.yaml`, you can bypass 
the unsafe 
certificate 
by running the following command in the browser:
- **thisisunsafe**

Just write it directly in the browser and it will bypass the unsafe certificate.

### Adminer
To get the url use `bash urls.sh`, it requires credentials:

Services: auth
- **Server**: db-{service}
- **Username**: jorge
- **Password**: 123456 




deseinstalar kubeconfomr
  hastar yamlint parece candiate y datree

### kustomize advance features
https://www.innoq.com/en/blog/advanced-kustomize-features/

### DATREE
Install Datree on your cluster
Add datree repo and create namespace
```bash
helm repo add datree-webhook https://datreeio.github.io/admission-webhook-datree
helm repo update
```
Install datree using Helm
```bash
helm install -n datree datree-webhook datree-webhook/datree-admission-webhook --debug \
                --create-namespace \
                --set datree.token=11c39b3e-7cd9-4c4f-9cb3-xxxxxxx \
                --set datree.clusterName=$(kubectl config current-context)
```


# every context in minikube has an ip, if ingress is uses it need to be cahnge in /etc/hosts


# documentar mejor el nfs kinda thisngggg

# todo scripts the nfs y documentacion the nfs
# digital ocean test with secrets 

# remeber to alwayusupdate the sealed secrets if a secret is changed
# skaffold overlay uses the sealed secrets of minikube