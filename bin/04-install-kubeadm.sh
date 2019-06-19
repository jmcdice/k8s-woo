#!/usr/bin/env bash
#
# Install kube* binaries

NODES=$(gcloud compute instances list | grep ^kube | awk '{print $1}')

function install_kube_utils() {

  APT='deb https://apt.kubernetes.io/ kubernetes-xenial main'

  for NODE in $NODES; do
    echo "Updating: ${NODE}"
    gcloud --quiet compute ssh ${NODE} -- "sudo apt-get update && sudo apt-get install -y apt-transport-https curl"
    gcloud --quiet compute ssh ${NODE} -- "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -"
    gcloud --quiet compute ssh ${NODE} -- "sudo sh -c 'echo ${APT} >/etc/apt/sources.list.d/kubernetes.list'"
    gcloud --quiet compute ssh ${NODE} -- "sudo apt-get update"
    gcloud --quiet compute ssh ${NODE} -- "sudo apt-get install -y kubelet kubeadm kubectl"
    gcloud --quiet compute ssh ${NODE} -- "sudo apt-mark hold kubelet kubeadm kubectl"
  done
}

function setup_bash_completion() {

  local NODE='kube-master'
  gcloud --quiet compute ssh ${NODE} -- "sudo apt-get -y install bash-completion"
  gcloud --quiet compute ssh ${NODE} -- 'echo "source <(kubectl completion bash)" >> ~/.bashrc'
}

install_kube_utils
setup_bash_completion
