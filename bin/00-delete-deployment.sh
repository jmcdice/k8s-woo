#!/usr/bin/env bash
#
# Delete the k8s deployment, VM's, networking, firewalls, everything.

NETWORK_NAME="kubenet"
SUBNET_NAME="kube-subnet"
CIDR='172.16.0.0/24'

function delete_stack() {

  # Delete our kubectl config file
  if [ -f config ]; then
    rm -f config
  fi

  for VM in kube-master kube-worker-1 kube-worker-2; do
    gcloud --quiet compute instances delete ${VM}
  done
  gcloud --quiet compute firewall-rules delete ${NETWORK_NAME}-allow-internal
  gcloud --quiet compute firewall-rules delete ${NETWORK_NAME}-allow-external
  gcloud --quiet compute firewall-rules delete istio-sample-app
  gcloud --quiet compute networks subnets delete ${SUBNET_NAME}
  gcloud --quiet compute networks delete ${NETWORK_NAME}
}

delete_stack
