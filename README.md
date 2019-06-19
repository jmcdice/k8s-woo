## Kubernetes from Scratch on GCP: A learning excercise.

The scripts in this repo will create a functioning kubernetes installation with popular components. It's meant to be executed one by one, such that a person can try to understand each step in the process. To execute all of them and simply get a running k8s cluster simply run the run_all.sh script.

## Initialize/pave some infrastructure in GCP:
  * Create a VPC network called kubenet
  * Create a subnet called kubenet-subnet (172.16.0.0/24)
  * Create firewall rules (tcp:22 (ssh) tcp:6443 (kubeapi))
  * Boot 3 Ubuntu 18.04 VM's

```console
  $ bash 01-configure-gcp.sh
```

## Setup DNS
  * Add an entry for each cluster node to each VM's /etc/hosts file 

```console
  $ bash 02-configure-dns.sh
```

## Install docker on all cluster nodes. 
- Install docker
- Update docker config to use systemd for cgroup management
- Create internal subnet for docker (172.17.0.0/16)
- Create interface docker0 (ifconfig docker0) 172.17.0.1
- Add routes for docker subnet 172.17.0.0/16 -> docker0
- Create iptables rules for networking

```console
  $ bash 03-install-docker.sh
```

## Install k8s utilities
  * Install kubelet, kubeadm, kubectl on all cluster nodes.

```console
  $ bash 04-install-kubeadm.sh
```

## Install cluster master components:
### https://kubernetes.io/docs/concepts/overview/components/#master-components
- Run kubeadm init
  * Setup kubectl access for default user
  * Add external kube-master VM IP to SSL Cert
  * kubeadm init (start kube-system master processes)
    * Boot kube-system containers:
      * kube-system   coredns
      * kube-system   etcd-kube-master
      * kube-system   kube-apiserver-kube-master
      * kube-system   kube-controller-manager-kube-master
      * kube-system   kube-proxy
      * kube-system   kube-scheduler-kube-master
  * Install kube-flannel for overlay network (10.244.0.0/16)
      * https://github.com/coreos/flannel/blob/master/Documentation/kubernetes.md
      * Create security policy, cluster role, role binding and service account.
      * API Extensions added for flannel
      * Start flannel container on the master 
        * kube-system   kube-flannel
  * Add kube-worker-1 and kube-worker-2 to the cluster
    * Starts 4 docker containers on the worker nodes
      * k8s_kube-flannel_kube-flannel
      * k8s_kube-proxy_kube-proxy
      * k8s_POD_kube-proxy
      * k8s_POD_kube-flannel
    * Adds interface and routes for: flannel.1 
      * kube-master   (10.244.0.0/32)
      * kube-worker-1 (10.244.1.0/32)
      * kube-worker-2 (10.244.2.0/32)

```console
  $ bash 05-configure-kubeadm.sh
```

## Enable remote access for kubectl

```console
  $ bash 06-configure-kubectl.sh
```

## Deploy the k8s Dashboard, create admin user and issue a token

```console
  $ bash 07-install-dashboard.sh
```

## Setup and deploy persistant disk volumes.

```console
  $ bash 08-configure-storage.sh
```

## Setup helm

```console
  $ bash 09-install-helm.sh
```

## Deploy a simple app (Linux desktop)
* Currently does nothing.
```console
  $ bash 10-install-test-app.sh
```

## Install Istio

```console
  $ bash 11-install-istio.sh
```

## Deploy Istio App and create FW rule.

```console
  $ bash 12-install-istio-app.sh
```

## To simply run everything, you can do:

```console
  $ bash run_all.sh
```

## Delete the entire deployment (wipe everything)

```console
  $ 00-delete-deployment.sh
```
