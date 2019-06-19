#!/usr/bin/env bash
#
# Allow remote access for kubeapi

NODE='kube-master'

function setup_remote_kube_api() {

    gcloud --quiet compute scp ${NODE}:.kube/config .
    EXT_IP=$(gcloud compute instances list|grep kube-master|awk '{print $5}')
    INT_IP=$(gcloud compute instances list|grep kube-master|awk '{print $4}')

    sed -i '' "s/${INT_IP}/${EXT_IP}/g" config

    echo "Run: export KUBECONFIG=./config"
}

setup_remote_kube_api
