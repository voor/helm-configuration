# Helmfile Kubernetes Configurations

Various Kubernetes configurations you can use in your clusters to achieve various results.

## Customizing

If you want to work with this repository, take a look at `envs/homelab/envs.sh` -- it will contain the majority of "must change" variables to get started.  There are definitely some other oddities in these files, and this repository while intended to be a good starting point is not meant for a "grab this and go" kind of scenario.  More than happy to work with anyone interested in consuming parts of this.

**Note**, I do things a little weird on my network, and deploy on `192.168.2.0/24`, so you might need to do some find/replace to get the desired effect.

Specifically, for Ops Man, I have the following network configuration:

```
networks-configuration:
  icmp_checks_enabled: true
  networks:
  - name: network
    subnets:
    - iaas_identifier: VM Network
      cidr: 192.168.2.0/24
      dns: 192.168.2.3,192.168.2.2
      gateway: 192.168.2.1
      reserved_ip_ranges: 192.168.2.0-192.168.2.6,192.168.2.38-192.168.2.255
      availability_zone_names:
      - az
```

## Install Helm (Tillerless), Helm-X, Helm Diff, and source configuration options

```
# Ease of use plugins.
helm plugin install https://github.com/mumoshu/helm-x
helm plugin install https://github.com/databus23/helm-diff --version master

# Open in another terminal
tiller --storage=secret
# Don't do this yet, helm-x is broken for dependency command.
# alias helmfile='helmfile -b ~/.helm/plugins/helm-x/bin/helm-x'

# Make sure you have in your terminal using helmfile:
source ./envs/homelab/envs.sh
```


# Install MetalLB

```
helmfile -l name=metallb sync
```

# Install nginx ingress

```
kubectl create ns ingress-nginx || :
# Created using Let's Encrypt dehydrated with DNS challenge.
kubectl -n ingress-nginx create secret tls default-ssl-certificate --key privkey.pem --cert fullchain.pem
helmfile -l name=nginx-ingress sync
```

# Install Harbor

```
kubectl create ns harbor-system
kubectl create secret -n harbor-system generic harbor-ingress --from-file=ca.crt=ca.pem --from-file=tls.crt=fullchain.pem --from-file=tls.key=privkey.pem
kubectl create secret -n harbor-system generic notary-certs --from-file=ca=ca.crt --from-file=crt=server.crt --from-file=key=server.key

kubectl create secret generic -n harbor-system harbor-postgres-postgresql-admin --from-literal=postgresql-password="${HARBOR_DATABASE_PASSWORD}" --from-literal=postgresql-replication-password="${HARBOR_DATABASE_PASSWORD}"

uaac client add ${HARBOR_UAA_CLIENT_ID} --scope openid \
  --authorized_grant_types client_credentials,password,refresh_token \
  --redirect_uri "https://${HARBOR_DNS}  https://${HARBOR_DNS}/*" \
  --secret "${HARBOR_UAA_CLIENT_SECRET}" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read

curl -X PUT -u "admin:${HARBOR_ADMIN_PASSWORD}" -H "Content-Type: application/json" -ki "https://${HARBOR_DNS}/api/configurations" -d "$(sed -e "s|\${HARBOR_UAA_CLIENT_SECRET}|${HARBOR_UAA_CLIENT_SECRET}|" -e "s|\${UAA_URL}|${UAA_URL}|" harbor/auth.example.json)"

helmfile -l name=harbor sync

# Log in once with your UAA user then log out
# Log back in with the admin account and make your user an Admin.
```

# Installing Concourse

```
kubectl create ns concourse-system
kubectl create ns concourse-main
kubectl create secret generic -n concourse-system concourse-postgres-postgresql-admin --from-literal=postgresql-password="${CONCOURSE_POSTGRES_ADMIN_PASSWORD}" --from-literal=postgresql-replication-password="${CONCOURSE_POSTGRES_ADMIN_PASSWORD}" 

uaac client add ${CONCOURSE_OIDC_CLIENT_ID} --scope openid,roles,uaa.user \
   --authorized_grant_types refresh_token,password,authorization_code \
   --redirect_uri "https://${CONCOURSE_DNS}/sky/issuer/callback" \
   --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read \
   --secret "${CONCOURSE_OIDC_CLIENT_SECRET}"

helmfile -l namespace=concourse-system sync
```


# Install Minio

```
kubectl create ns minio-system
kubectl apply -f minio/minio-datastore-pv.yml
helmfile -l name=minio sync
```


# Install GitLab

```
uaac client add ${GITLAB_UAA_CLIENT_ID} --scope openid,roles,uaa.user,email,profile \
  --authorized_grant_types refresh_token,authorization_code \
  --redirect_uri "https://${GITLAB_DNS}/users/auth/openid_connect/callback" \
  --authorities clients.read,clients.secret,uaa.resource,scim.write,openid,scim.read \
  --secret "${GITLAB_UAA_CLIENT_SECRET}"

# Create NS
kubectl create ns gitlab-system
# Add ingress secret
kubectl create secret -n gitlab-system tls gitlab-ingress --cert=fullchain.pem --key=privkey.pem --dry-run -o yaml | kubectl apply -f -
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
kubectl create secret generic -n gitlab-system gitlab-postgres-postgresql --from-literal=postgresql-password="E1en5tbYPt"

kubectl create secret generic -n gitlab-system gitlab-pks-auth --from-file=provider=pks-provider.yml
```

### Test

Make sure the install worked properly.

```
kubectl run -i --rm --tty harbor-database-test --image=bitnami/mariadb --restart=Never -- mysql -h harbor-database-mariadb.harbor.svc.cluster.local -u root -p${MARIADB_ROOT_PASSWORD}
```

Also make sure you mounted everything properly in the master database:

```
kubectl exec -it harbor-database-mariadb-master-0 -n harbor -- /bin/bash
```
