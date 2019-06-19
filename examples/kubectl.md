## Commands to be aware of with kubectl

# Resource Examples
nodes (no)
pods (po)
services (svc)
persistant volumes (pv)
persistant voluem claims (pvc)

# Format
```console
  $ kubectl [command] [type] [name] [flags]
  $ kubectl get nodes --output wide
```

# Create a resource
```console
  $ kubectl apply/create 
```

# Start a pod from an image
```console
  $ kubectl run
```

# Resource documentation
```console
  $ kubectl explain
```

# Delete resources
```console
  $ kubectl delete 
```

# List resources
```console
  $ kubectl get
```

# Describe an existing resource
```console
  $ kubectl describe
```

# Run a command inside a container
```console
  $ kubectl exec
```

# Look at container logs
```console
  $ kubectl logs
```


# Starter Examples after the cluster is up

# Look at cluster info
```console
  $ kubectl cluster-info
  $ kubectl cluster-info dump
  $ kubectl get pods --namespace kube-system -o wide
  $ kubectl get all --all-namespaces 
  $ kubectl api-resources 
  $ kubectl explain pod
  $ kubectl explain pod.spec
  $ kubectl explain pod.spec.containers
  $ kubectl describe nodes kube-master
  $ kubectl exec -it <pod-name> -- /bin/bash
  $ kubectl get deployment hello-world
  $ kubectl get replicaset
  $ kubectl expose deployment <deployment> --port=<internet facing port> --target-port=<container service port>
  $ kubectl get endpoints <deployment>



```


