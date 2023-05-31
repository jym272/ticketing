# Minikube
**Contents**
1. [Profiles](#profiles)
2. [Create Sealed Secrets](#create-sealed-secrets)
3. [Enable ingress](#enable-ingress)
4. [Enable metrics-server](#enable-metrics-server)
5. [Apply](#apply)
   1. [Minikube](#minikube)
   2. [Multinodes](#multinodes)
6. [NFS Volumes for multinodes profile](#nfs-volumes-for-multinodes-profile)
   1. [Quick explanation](#quick-explanation)
7. [Delete](#delete)
    1. [Minikube](#minikube)
    2. [Multinodes](#multinodes)
---
## Profiles
Two profiles are available, `minikube` and `multinodes`.

> **Minikube** profile uses one node, a volume `hostPath` is attached to the minikube node. If this 
  minikube profile is erased, the data is lost. Start the profile with:
   > ```bash
   > minikube start --cpus=max --memory 12288 -p minikube --driver kvm2
   > ```

> **Multinodes** uses `nfs`, the data is storage in the host machine, if the minikube profile 
`multinodes` is erased, the data is not lost. Start the profile with:
   > ```bash
   > minikube start --nodes 4 --cpus 3 --memory 4096 -p multinodes --driver kvm2
   > ```
---

## Create Sealed Secrets
For secrets management `sealed-secrets` is used.
Follow the
[instructions.](../../../scripts/README.md#using-sealedsecrets-for-secret-management) Sealed 
Secrets is not optional, must be installed in the cluster.
---

## Enable ingress
Follow the commands, if the browser shows site not secure, type `thisisunsafe` to continue
```bash
minikube addons enable ingress -p [minikube|multinodes]
```
To get the `ip` of `minikube`
```bash
minikube -p profile_name ip # 192.168.39.193
```
Set in `/etc/hosts` any domain name, for example **ticketing.dev** configure the domain name in
`ingress.yml` also.

```bash
cat /etc/hosts
# 127.0.0.1       localhost
# 192.168.39.193  ticketing.dev
# ::1             localhost
# 127.0.1.1       pop-os.localdomain      pop-os
```
---

## Enable metrics-server
>To enable the use of metrics in the microservices project for **autoscaling purposes**,
you need to install the **Metrics Server** addon in your `minikube` cluster.

To enable the **Metrics Server** in your `minikube` cluster, which provides metrics used by the
**Horizontal Pod Autoscaler** and the **Vertical Pod Autoscaler** 
(although the latter is not implemented in this project), you can use the following command:
```bash
minikube addons enable metrics-server -p [minikube|multinodes]
```
By executing this command, the Metrics Server addon will be activated in your Minikube cluster, 
allowing you to collect and utilize metrics for autoscaling purposes. 
The Horizontal Pod Autoscaler 
uses these metrics to adjust the number of replicas for your pods based on resource utilization, 
while the Vertical Pod Autoscaler, even though not implemented in this project, 
leverages metrics to optimize resource requests and limits for individual containers within pods. 

For more information on the Vertical Pod Autoscaler, you can refer to the 
[official GitHub repository](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#vertical-pod-autoscaler).

---
## Apply
### Minikube
To apply the manifest files, use the following command:
```bash
kubectl apply -k k8s/overlay/minikube
```
### Multinodes
Before applying the manifest files to `multinodes` profile, you need to configure first the 
**NFS Volumes**, then to apply the manifest files, use the following command:
```bash
kubectl apply -k k8s/overlay/multinodes/storage
kubectl apply -k k8s/overlay/multinodes
```
---
## NFS Volumes for multinodes profile
Only for `multinodes` profile, for `minikube` profile the `hostPath` volume is already set in `base`

To configure NFS Volumes use the scripts: 
- [change_nfs_server_address.sh](../multinodes/change_nfs_server_address.sh)
  > The script updates the value of  `nfs.server` in the `overlay/multinodes/storage` kustomization 
  > file. The value is the  `minikube_gateway_address`.
- [create_nfs_exports.sh](../multinodes/create_nfs_exports.sh)
  > This script creates directories for the volumes, assigns ownership to them, and sets up NFS 
  > export entries for each directory. If any new NFS exports are added, it exports the shares and restarts the NFS server.
  > 
  > The **NFS Server** needs to be run on the host machine, not in the minikube VM. Check if the
  > NFS server is installed and running with the following commands:
  > ```bash
  > dpkg -l | grep nfs-kernel-server
  > service nfs-kernel-serve3r status
  > ```
  > If the server is not installed, install it and start it with the following commands:
  > ```bash
  > sudo apt install nfs-kernel-server
  > sudo systemctl start nfs-kernel-server
  > sudo systemctl enable nfs-kernel-server
  > sudo systemctl status nfs-kernel-server
  > ```

### Quick explanation
[Reference]

First, we need to install the NFS Server and create the NFS export directory on our host
```bash
sudo apt install nfs-kernel-server
sudo mkdir -p /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share/
```
Then, we need to configure the NFS server by editing the `/etc/exports` file
```text
$ sudo vim /etc/exports
Add the following line to the file:
 /mnt/nfs_share  *(rw,sync,no_subtree_check,no_root_squash,insecure)
```
Then, export all directories listed in the /etc/exports file. `-a` option instructs the server to 
make any new or modified exports available to NFS clients. Then restart the NFS server.
```bash
sudo exportfs -a && sudo systemctl restart nfs-kernel-server
```
We can use the `exportfs -v` command to display the current export list
```shell
sudo exportfs -v
```
Now, we need to find the IP address of our host machine
```bash
minikube -p multinodes ssh
$ ip r | grep default # 192.168.49.1
# or also this cmd:
ip route | grep default | awk '{print $3}'

```
Example of a PVC:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-volume
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  nfs:
    server: 192.168.49.1
    path: "/mnt/nfs_share"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-claim
  namespace: default
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi

```
---
## Delete
### Minikube
To delete the manifest files, use the following command:
```bash
kubectl delete -k k8s/overlay/minikube
```
### Multinodes
To delete the manifest files, use the following command:

```bash
kubectl delete -k k8s/overlay/multinodes
```
The creation of the NFS Volumes is not deleted because it was dynamically created by the **StatefulSet**.
First, delete the **PVCs** that was created dynamically by the **StatefulSet**.
```bash
kubectl delete pvc --all
```
Then, delete the NFS Volumes
```bash
kubectl delete -k k8s/overlay/multinodes/storage
```
If the manifest are going to be applied again, the NFS directories need to be reset.
```bash
sudo rm -rf /data/*
bash multinodes/create_nfs_exports.sh
```

[Reference]:https://stackoverflow.com/questions/70878064/mounting-volume-for-two-nodes-in-minikube