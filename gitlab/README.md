Make sure the ingress controller is exposing TCP port 22 for gitlab shell.

```
# Create NS
kubectl create ns gitlab-system
# Add ingress secret
kubectl create secret -n gitlab-system tls gitlab-ingress --cert=certs/planetvoor.com/fullchain.pem --key=certs/planetvoor.com/privkey.pem --dry-run -o yaml | kubectl replace -f -
# Add smtp-password secret
echo -n $PASSWORD > password
kubectl create secret generic -n gitlab-system smtp-password --from-file=password -o yaml --dry-run | kubectl replace -f -
rm password
sed -e "s/\$MINIO_ACCESS_KEY/$MINIO_ACCESS_KEY/" -e "s/\$MINIO_SECRET_KEY/$MINIO_SECRET_KEY/" -e "s/\$MINIO_DNS/$MINIO_DNS/" rails.example.yml > rails.yml
kubectl create secret -n gitlab-system generic objectstore \
    --from-file=connection=rails.yml
rm rails.yml
sed "s/\$MINIO_ACCESS_KEY/$MINIO_ACCESS_KEY/" -e "s/\$MINIO_SECRET_KEY/$MINIO_SECRET_KEY/" -e "s/\$MINIO_DNS/$MINIO_DNS/" registry.example.yml > registry.yml
kubectl create secret -n gitlab-system generic registry-storage \
    --from-file=config=registry.yml
rm registry.yml
kubectl apply -f gitaly-datastore-pv.yml -f gitlab-admin.yml -f gitlab-pvc.yml

# Create postgres password
kubectl create secret generic -n gitlab-system gitlab-postgres-postgresql --from-literal=postgresql-password="$GITLAB_POSTGRESQL_PASSWORD"

kubectl create secret generic -n gitlab-system gitlab-pks-auth --from-file=provider=pks-provider.yml
```

```
create database gitlab;
```

## Runners

```
kubectl create secret generic s3access \
     --from-literal=accesskey="$MINIO_ACCESS_KEY" \
     --from-literal=secretkey="$MINIO_SECRET_KEY"
helm install ~/git/gitlab-runner --namespace gitlab-runner --name gitlab-runner --values ~/git/pks-configuration/gitlab/gitlab-runner-values.yaml
```


## Maintenance

Mounting a volume to inspect contents.

```
kubectl run -i --rm --tty debian --overrides='
{
  "spec": {
    "containers": [
      {
        "name": "debian",
        "image": "debian:sid-slim",
        "args": ["bash"],
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "volumeMounts": [
          {
            "mountPath": "/mnt",
            "name": "store"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "store",
        "vsphereVolume": {
          "volumePath": "[storage01] volumes/etcd001",
          "fsType": "ext4"
        }
      }
    ]
  }
}
'  --image=debian:sid-slim --restart=Never -- bash
```