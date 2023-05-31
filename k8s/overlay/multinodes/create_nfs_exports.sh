#!/usr/bin/env bash

set -eou pipefail
# Create NFS exports for the NFS server
declare -a dirs=("/data/postgres-orders" "/data/postgres-auth" "/data/redis" "/data/jetstream" "/data/postgres-payments" "/data/postgres-tickets")

function green_echo {
  echo -e "\033[32m$1\033[0m"
}

# for to the dirs and $ sudo mkdir -p /mnt/nfs_share && sudo chown -R nobody:nogroup /mnt/nfs_share/
# first create check if the dir is already cretaed, if not create it and chown it
exportfs_flag=0
for dir in "${dirs[@]}"
do
  if [ ! -d "$dir" ]; then
    green_echo "Creating $dir"
    sudo mkdir -p "$dir"
    # if dir is "/data/postgres-orders" or "/data/postgres-tickets" also create the subdirs a,b,c
    if [ "$dir" == "/data/postgres-orders" ] || [ "$dir" == "/data/postgres-tickets" ]; then
      green_echo "Creating subdirs a,b,c for $dir"
      sudo mkdir -p "$dir"/{a,b,c}
    fi
    sudo chown -R nobody:nogroup "$dir"
    green_echo "Creating NFS export for $dir"
    export_line="$dir *(rw,sync,no_subtree_check,no_root_squash,insecure)"
    # first find export_line in /etc/exports, if not found then append it
    if grep -Fxq "$export_line" /etc/exports; then
      echo "$export_line already exists in /etc/exports"
    else
      echo "$export_line" | sudo tee -a /etc/exports
      exportfs_flag=1
    fi
  fi
done

# if flag is given sudo exportfs -a && sudo systemctl restart nfs-kernel-server
if [ $exportfs_flag -eq 1 ]; then
  green_echo "Exporting NFS shares"
  sudo exportfs -ra
  green_echo "Restarting NFS server"
  sudo systemctl restart nfs-kernel-server
fi

