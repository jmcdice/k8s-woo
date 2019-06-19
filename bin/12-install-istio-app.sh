#!/usr/bin/env bash
#
# Install and configure Istio service mesh
# Deploy a sample app and create an Istio gateway for access.


function deploy_sample_app() {

  export KUBECONFIG=./config

  local NODE='kube-master'
  gcloud --quiet compute ssh ${NODE} -- 'cd istio-1.1.8/ && kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml'
  gcloud --quiet compute ssh ${NODE} -- 'cd istio-1.1.8/ && kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml'

  # Allow access to the gateway port from the Internet.
  #gcloud --quiet compute firewall-rules update kubenet-allow-external \
  #  --allow tcp:22,tcp:6443,icmp

  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
  NODE=$(kubectl describe pod -l istio=ingressgateway -n istio-system |grep ^Node:|awk '{print $2}'|awk -F \/ '{print $1}')
  INGRESS_HOST=$(gcloud compute instances list|grep ^${NODE}|awk '{print $5}')
  GATEWAY_URL="$INGRESS_HOST:$INGRESS_PORT"

  # Allow access to the gateway port from the Internet.
  gcloud --quiet compute firewall-rules create istio-sample-app \
    --allow tcp:${INGRESS_PORT} \
    --network kubenet \
    --source-ranges 0.0.0.0/0

  echo "export INGRESS_HOST=${INGRESS_HOST}"
  echo "export INGRESS_PORT=${INGRESS_PORT}"
  echo "export SECURE_INGRESS_PORT=${SECURE_INGRESS_PORT}"
  echo "export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT"
  echo "curl -s http://${GATEWAY_URL}/productpage"
}

deploy_sample_app
