#!/usr/bin/env bash
#
# Create persistant volumes on our worker nodes

NODES=$(gcloud compute instances list | grep ^kube | grep worker | awk '{print $1}')

function create_persistant_volumes() {

  # Create 10 directories, representing 10 attached persistant volumes
  # Create a config for each and apply it to the cluster.
  # In prod, these would be attached cloud disks (gcloud compute disks create ...)

  VOL_CONFIG='persistant_volume.yml'

  for NODE in $NODES; do
    rm -f ${VOL_CONFIG}
    echo "Storage Config for: ${NODE}"
    for VOL in {1..10}; do

cat <<EOF >> ${VOL_CONFIG}
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${NODE}-disk-${VOL}
  labels:
    types: hdd
spec:
  storageClassName: default
  capacity:
    storage: 10Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  - ReadOnlyMany
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: /mnt/${NODE}-disk-${VOL}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - ${NODE}
---
EOF
    done

    gcloud --quiet compute ssh ${NODE} -- "sudo mkdir -p /mnt/${NODE}-disk-{1..10}"
    gcloud --quiet compute scp ${VOL_CONFIG} kube-master:
    gcloud --quiet compute ssh kube-master -- "kubectl apply -f ${VOL_CONFIG}"
  done
  rm -f ${VOL_CONFIG}
}

function create_storage_class() {

  SC_CONFIG='storage_class.yml'

cat >> ${SC_CONFIG} <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  namespace: default
  name: default
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

    gcloud --quiet compute scp ${SC_CONFIG} kube-master:
    gcloud --quiet compute ssh kube-master -- "kubectl apply -f ${SC_CONFIG}"
    rm -f ${SC_CONFIG}
}

create_storage_class
create_persistant_volumes
