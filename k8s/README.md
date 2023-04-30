### NFS in host -> PV for multinodes
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


[Reference]:https://stackoverflow.com/questions/70878064/mounting-volume-for-two-nodes-in-minikube