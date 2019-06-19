#!/usr/bin/env bash
#
# Install and configure Istio service mesh
# Deploy a sample app and create an Istio gateway for access.

function install_istio() {

  local NODE='kube-master'

  echo "Installing Istio on: ${NODE}"
  gcloud --quiet compute ssh ${NODE} -- 'curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.8 sh -'
  gcloud --quiet compute ssh ${NODE} -- 'cd istio-1.1.8/ && /snap/bin/helm install install/kubernetes/helm/istio-init \
                                         --set gateways.istio-ingressgateway.type=NodePort \
  					 --name istio-init --namespace istio-system'

  # Wait for this to get happy or the subsequent commands fail.
  while [ "${CREDS_READY}" != "53" ]; do
    echo "Sleeping for 10s while Istio is configured."
    sleep 10
    CREDS_READY=$(gcloud --quiet compute ssh ${NODE} -- 'kubectl get crds | grep "istio.io\|certmanager.k8s.io" | wc -l')
    CREDS_READY=${CREDS_READY%?};
  done 

  gcloud --quiet compute ssh ${NODE} -- 'cd istio-1.1.8 && /snap/bin/helm install install/kubernetes/helm/istio \
  					  --name istio --namespace istio-system \
  					  --values install/kubernetes/helm/istio/values-istio-demo-auth.yaml \
  					  --set gateways.istio-ingressgateway.type=NodePort'
  gcloud --quiet compute ssh ${NODE} -- 'kubectl label namespace default istio-injection=enabled'
  gcloud --quiet compute ssh ${NODE} -- 'kubectl get namespace -L istio-injection'
}

install_istio
