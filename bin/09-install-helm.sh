#!/usr/bin/env bash
#
# Install and configure Helm on kube-master


function install_helm() {

  local NODE='kube-master'
  echo "Installing helm on: ${NODE}"
  gcloud --quiet compute ssh ${NODE} -- 'sudo snap install helm --classic'
  gcloud --quiet compute ssh ${NODE} -- 'kubectl create serviceaccount --namespace kube-system tiller'
  gcloud --quiet compute ssh ${NODE} -- 'kubectl create clusterrolebinding tiller-cluster-rule \
					  --clusterrole=cluster-admin --serviceaccount=kube-system:tiller'
  gcloud --quiet compute ssh ${NODE} -- '/snap/bin/helm init --service-account tiller'
  gcloud --quiet compute ssh ${NODE} -- '/snap/bin/helm repo update'

  # These 2 can be deleted later.
  gcloud --quiet compute ssh ${NODE} -- 'kubectl get po -n kube-system'
  gcloud --quiet compute ssh ${NODE} -- '/snap/bin/helm version'

  # Loop until helm's tiller pod gets happy.
  gcloud --quiet compute ssh ${NODE} -- '/snap/bin/helm version' | grep -q Server:
  while [ $? -ne 0 ]; do
    gcloud --quiet compute ssh ${NODE} -- '/snap/bin/helm version' | grep -q Server:
  done
}

install_helm

