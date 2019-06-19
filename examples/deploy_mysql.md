# Deploy mysqld via the helm chart, then connect to it with a mysql client.

```console
  $ gcloud compute ssh kube-master
  $ helm install --name=mysql stable/mysql
```

# Note the mysql server pod IP
```console
  $ kubectl get pods -o wide
```

# Get the mysql root password and create the mysql client
```console
  $ kubectl get secret --namespace default mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo
```

# Boot up an ubuntu container to run the client
```console
  $ kubectl run -i --tty ubuntu-client --image=ubuntu:16.04 --restart=Never 
  $ apt-get update && apt-get install mysql-client -y
  $ mysql -h <POD_IP> -u root -p <password>
```
