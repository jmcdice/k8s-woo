#!/usr/bin/env bash
#
# Create a network and subnet
# Add firewall rules
# Boot three VM's and attach them to the subnet
# kube-master 
# kube-worker-1
# kube-worker-2

NETWORK_NAME="kubenet"
SUBNET_NAME="kube-subnet"
CIDR='172.16.0.0/24'

function create_stack() {

  gcloud --quiet compute networks create ${NETWORK_NAME} --subnet-mode custom

  gcloud --quiet compute networks subnets create ${SUBNET_NAME} \
    --network ${NETWORK_NAME} \
    --range ${CIDR}

  gcloud --quiet compute firewall-rules create ${NETWORK_NAME}-allow-internal \
    --allow tcp,udp,icmp \
    --network ${NETWORK_NAME} \
    --source-ranges ${CIDR}

  gcloud --quiet compute firewall-rules create ${NETWORK_NAME}-allow-external \
    --allow tcp:22,tcp:6443,icmp \
    --network ${NETWORK_NAME} \
    --source-ranges 0.0.0.0/0

  for VM in kube-master kube-worker-1 kube-worker-2; do
    gcloud --quiet compute instances create ${VM} \
      --async \
      --boot-disk-size 100GB \
      --image-family ubuntu-1804-lts \
      --image-project ubuntu-os-cloud \
      --machine-type n1-standard-1 \
      --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
      --subnet ${SUBNET_NAME} \
      --tags ${NETWORK_NAME}

  done
}

create_stack

# Wait until the computes are happy before moving on.
gcloud compute instances list | grep ^kube | grep -q STAGING
while [ $? -eq 0 ]; do
  echo "VM's staging.."
  sleep 15;
  gcloud compute instances list | grep ^kube | grep -q STAGING
done
