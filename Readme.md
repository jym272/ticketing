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

