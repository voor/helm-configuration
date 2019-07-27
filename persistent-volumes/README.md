# Persistent Volumes

Check out [Persistent Volumes & Persistent Volumes Claims](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/persistent-vols-claims.html), which explains how to create persistent volumes ahead of time using `vmkfstools`

## Create new VMDK

```
ssh root@esxi01.planetvoor.com
vmkfstools -c 3G /vmfs/volumes/storage01/volumes/harbor-database.vmdk
```

## Quickly Test a Volume

### vSphere Volume

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

### NFS Client

```
kubectl apply -f volumes.yml
kubectl apply -f claims.yml
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
        "persistentVolumeClaim": {
          "claimName": "storage-mnt-storage"
        }
      }
    ]
  }
}
'  --image=debian:sid-slim --restart=Never -- bash
```