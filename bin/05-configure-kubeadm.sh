#!/usr/bin/env bash
#
# Install kube* binaries and initalize the master node.
# Using the Flannel CNI (network overlay)
# Run the join command on the cluster workers.

function kubeadm_init() {

  FLANNEL_CONFIG='https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml'
  API_EXT_IP=$(gcloud compute instances list|grep kube-master|awk '{print $5}')
  INIT="kubeadm init --apiserver-cert-extra-sans=${API_EXT_IP} \
        --pod-network-cidr=10.244.0.0/16 \
        --ignore-preflight-errors=NumCPU"

  local NODE='kube-master'
  echo "Updating: ${NODE}"
  gcloud --quiet compute ssh ${NODE} -- "sudo ${INIT}"
  gcloud --quiet compute ssh ${NODE} -- 'mkdir -p .kube'
  gcloud --quiet compute ssh ${NODE} -- 'sudo cp -i /etc/kubernetes/admin.conf .kube/config'
  gcloud --quiet compute ssh ${NODE} -- 'sudo chown $(id -u):$(id -g) .kube/config'
  gcloud --quiet compute ssh ${NODE} -- "kubectl apply -f ${FLANNEL_CONFIG}"
}

function execute_join() {

  # This function will join the workers to the kubernetes cluster.
  JOIN=$(gcloud compute ssh kube-master -- "sudo kubeadm token create --print-join-command")
  JOIN=${JOIN%?}; # Remove eol from above command.
  NODES=$(gcloud compute instances list | grep ^kube | grep worker | awk '{print $1}')

  for NODE in $NODES; do
    gcloud --quiet compute ssh ${NODE} -- "sudo ${JOIN}"
  done
}

kubeadm_init
execute_join
