#!/usr/bin/env bash

# Putting this one in test mode.
exit

# gcloud container clusters get-credentials standard-cluster-1 --zone us-central1-a

DOCKER='pddenhar/docker-mint-vnc-desktop'
SERVICE='web-desktop'
INTERNAL_PORT='6080'
EXTERNAL_PORT='80'

function start_app() {
  kubectl --kubeconfig=config run web-desktop --image=${DOCKER} --port ${INTERNAL_PORT}
  kubectl --kubeconfig=config expose deployment ${SERVICE} --type=NodePort --port ${EXTERNAL_PORT}
}

function check_app() {
  kubectl get pods,service
}

function delete_app() {
  kubectl delete services ${SERVICE}
  kubectl delete deployment ${SERVICE}
}

start_app
check_app
# delete_app
