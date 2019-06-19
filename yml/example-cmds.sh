## PODs
# Create a pod
  $ kubectl create -f this-file.yml

# List pod
  $ kubectl get pods

# Describe pod
  $ kubectl describe pod app-name-pod

## Replica Set (collection of pods)
  $ kubectl create -f replica-set-definition.yml

# List replica set
  $ kubectl get replicaset

# List pods created by replicaset
  $ kubectl get pods

# Scale Pods
  $ vim replica-set-definition.yml
  # s/replica: 3/replica 6/
  $ kubectl replace -f replica-set-definition.yml
  $ kubectl scale-replicas=6 replica-set-definition.yml
  $ kubectl scale-replicas=6 replicaset my-app-replicaset

## Deployments (collection of replica sets)
# Provides updates and rollbacks
  $ kubectl create -f deployment-definition.yml

# List deployments
  $ kubectl get deployments

# List replica sets (automatically created)
  $ kubectl get replicaset

# List pods created by the deployment
  $ kubectl get pods

# List everything
  $ kubectl get all


