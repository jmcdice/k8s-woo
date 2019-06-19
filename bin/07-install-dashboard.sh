#!/usr/bin/env bash
#
# Deploy the kubernetes Dashboard.
# Create an admin user service account and bind a roll to it.
# Get the token for it.

function deploy_dashboard() {

  local NODE='kube-master'
  DASH='https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml'

  echo "Updating: ${NODE}"
  gcloud --quiet compute ssh ${NODE} -- "kubectl apply -f ${DASH}"
  gcloud --quiet compute scp ../yml/dashboard-admin-user.yml ${NODE}:
  gcloud --quiet compute scp ../yml/dashboard-role-binding.yml ${NODE}:
  gcloud --quiet compute ssh ${NODE} -- "kubectl apply -f dashboard-admin-user.yml"
  gcloud --quiet compute ssh ${NODE} -- "kubectl apply -f dashboard-role-binding.yml"
}

function get_token() {

  echo "kubectl proxy"
  echo "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"

  TOKEN=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')|grep token:|awk '{print $2}')
  echo $TOKEN
}

# Just show dashboard access info and exit:
#   bash 07-deploy-dashboard.sh token
if [ "$1" == "token" ]; then
  get_token
  exit 1;
fi

deploy_dashboard
