#!/usr/bin/env bash
#
# Populate /etc/hosts with cluster members.

NODES=$(gcloud compute instances list | grep ^kube | awk '{print $1}')

update_host_dns() {

  for NODE in $NODES; do

    HOSTS=$(gcloud compute instances list | grep ^kube | grep -v ${NODE} | awk '{print $4, $1}') 
    IFS=$'\n' 
    ETC=($HOSTS)

    echo "Updating: ${NODE}"
    for LINE in "${ETC[@]}"; do
      gcloud --quiet compute ssh ${NODE} -- "sudo sh -c 'echo ${LINE} >> /etc/hosts'"
    done
  done
}

update_host_dns
