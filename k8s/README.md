### Minkube 
Minikube one node, one thing to notice, the hostPath is attach to the minikube node, that's why 
is called `local`. If this minikube profile is erased, the data is lost.

Multinodes uses `nfs`, the data is storaged in the host machine, if the minikube profile 
`multinodes` is erased, the data is not lost.

```bash
minikube start --vm-driver kvm2 #the default profile is minikube    
```
Minkube multinodes 4
```bash
minikube start --nodes 4 --driver kvm2 -p multinodes
minikube start --nodes 2 --cpus 12 --memory 8192--disk-size 10g --namespace test -p s-node
minikube start --nodes 6 --cpus 12 --memory 8192 -p multinodes --driver kvm2
minikube start --nodes 6 -p multinodes --driver kvm2
```


### Enable ingress
Follow the commands, if the browser shows site not secure, type `thisisunsafe` to continue
```bash
minikube addons enable ingress -p profile_name
#get ip 
minikube -p profile_name ip # 192.168.39.193
# set in /etc/hosts - ticketing.dev is the domain name, config any name in ingress.yml
cat /etc/hosts
# 127.0.0.1       localhost
# 192.168.39.193  ticketing.dev
# ::1             localhost
# 127.0.1.1       pop-os.localdomain      pop-os

```



### NFS in host -> PV for multinodes
Use the scripts `change_nfs_server_address.sh` and `create_nfs_exports.sh`

Quick explanation: [ref] 

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
We can use the `exportfs -v command to display the current export list
```shell
sudo exportfs -v
```
Using the standard sc
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


[ref]:https://stackoverflow.com/questions/70878064/mounting-volume-for-two-nodes-in-minikube