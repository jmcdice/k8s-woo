#!/bin/bash

START=$(date +%s);
bash 00-delete-deployment.sh
bash 01-configure-gcp.sh
bash 02-configure-dns.sh
bash 03-install-docker.sh
bash 04-install-kubeadm.sh
bash 05-configure-kubeadm.sh
bash 06-configure-kubectl.sh
bash 07-install-dashboard.sh
bash 08-configure-storage.sh
bash 09-install-helm.sh
bash 10-install-test-app.sh
bash 11-install-istio.sh
bash 12-install-istio-app.sh

END=$(date +%s);
SECONDS=$(($END - $START));
MIN=$(($SECONDS / 60))
echo "Took: $MIN Minutes." 

