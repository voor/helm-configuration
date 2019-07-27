# Testing Harbor Stuff

## Ingress Secret

```
kubectl create secret -n harbor-system generic harbor-ingress --from-file=ca.crt=ca.pem --from-file=tls.crt=fullchain.pem --from-file=tls.key=privkey.pem
kubectl create secret -n harbor-system generic notary-certs --from-file=ca=ca.crt --from-file=crt=server.crt --from-file=key=server.key
```

## Helm install

```

```

## Run Notary with CA mounted

```
kubectl run -i --rm --tty harbor-notary-test --overrides='
{
  "spec": {
    "containers": [
      {
        "name": "harbor-notary-test",
        "image": "goharbor/notary-server-photon:dev",
        "args": ["bash"],
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "volumeMounts": [
          {
            "mountPath": "/etc/ssl/notary/cert/notary-signer-ca.crt",
            "name": "notary-ca",
            "subPath": "ca"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "notary-ca",
        "secret": {
          "secretName": "notary-ca"
        }
      }
    ]
  }
}
'  --image=goharbor/notary-server-photon:dev --restart=Never -n harbor-system -- bash

```


Everything:

```
kubectl run -i --rm --tty harbor-notary-test --overrides='
{
    "spec": {
        "containers": [
            {
                "args": ["bash"],        "stdin": true,
        "stdinOnce": true,
        "tty": true,
                "env": [
                    {
                        "name": "MIGRATIONS_PATH",
                        "value": "migrations/server/postgresql"
                    },
                    {
                        "name": "DB_URL",
                        "value": "postgres://postgres:changeit@harbor-harbor-database:5432/notaryserver?sslmode=disable"
                    }
                ],
                "image": "goharbor/notary-server-photon:dev",
                "imagePullPolicy": "IfNotPresent",
                "name": "notary-server",
                "resources": {},
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "volumeMounts": [
                    {
                        "mountPath": "/etc/notary",
                        "name": "notary-config"
                    },
                    {
                        "mountPath": "/root.crt",
                        "name": "root-certificate",
                        "subPath": "tls.crt"
                    },
                    {
                        "mountPath": "/etc/ssl/notary/cert/notary-signer-ca.crt",
                        "name": "notary-ca",
                        "subPath": "ca"
                    },
                    {
                        "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                        "name": "harbor-harbor-notary-serviceaccount-token-d82cf",
                        "readOnly": true
                    }
                ]
            }
        ],
        "restartPolicy": "Never",
        "serviceAccount": "harbor-harbor-notary-serviceaccount",
        "serviceAccountName": "harbor-harbor-notary-serviceaccount",
        "terminationGracePeriodSeconds": 30,
        "tolerations": [
            {
                "effect": "NoExecute",
                "key": "node.kubernetes.io/not-ready",
                "operator": "Exists",
                "tolerationSeconds": 300
            },
            {
                "effect": "NoExecute",
                "key": "node.kubernetes.io/unreachable",
                "operator": "Exists",
                "tolerationSeconds": 300
            }
        ],
        "volumes": [
            {
                "configMap": {
                    "defaultMode": 420,
                    "name": "harbor-harbor-notary-server"
                },
                "name": "notary-config"
            },
            {
                "name": "root-certificate",
                "secret": {
                    "defaultMode": 420,
                    "secretName": "harbor-harbor-core"
                }
            },
            {
                "name": "notary-ca",
                "secret": {
                    "defaultMode": 420,
                    "secretName": "notary-ca"
                }
            },
            {
                "name": "harbor-harbor-notary-serviceaccount-token-d82cf",
                "secret": {
                    "defaultMode": 420,
                    "secretName": "harbor-harbor-notary-serviceaccount-token-d82cf"
                }
            }
        ]
    }
}
'  --image=goharbor/notary-server-photon:dev --restart=Never -n harbor-system -- bash
```