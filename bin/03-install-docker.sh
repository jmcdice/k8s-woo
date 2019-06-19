#!/usr/bin/env bash
#
# Install Docker on the compute nodes

NODES=$(gcloud compute instances list | grep ^kube | awk '{print $1}')

function install_docker() {
  for NODE in $NODES; do
    echo "Installing docker on: ${NODE}"
    gcloud --quiet compute ssh ${NODE} -- 'sudo apt-get update && sudo apt-get -y install docker.io'
    gcloud --quiet compute ssh ${NODE} -- 'sudo systemctl enable docker.service'
  done
}

function update_docker_config() {

  # Control groups are used and managed by the systemd process on Ubuntu.
  # Docker does that too for containers. Tell docker to use systemd so we
  # don't make the system unstable.

cat > daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

  for NODE in $NODES; do
    local DEST='/etc/docker/daemon.json'
    gcloud --quiet compute scp daemon.json ${NODE}:
    gcloud --quiet compute ssh ${NODE} -- "sudo mv daemon.json ${DEST} && sudo chown root:root ${DEST}"
    gcloud --quiet compute ssh ${NODE} -- 'sudo mkdir -p /etc/systemd/system/docker.service.d'
    gcloud --quiet compute ssh ${NODE} -- 'sudo systemctl daemon-reload'
    gcloud --quiet compute ssh ${NODE} -- 'sudo systemctl restart docker'
  done
  rm -f daemon.json
}

install_docker
update_docker_config
