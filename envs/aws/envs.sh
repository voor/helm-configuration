#!/bin/bash

# relative or absolute path of your envs directory, effectively where the directory
# containing this script sits relative to the helmfile dir.
export ENV_DIR="./envs/aws/"

# For keeping this in sync with what I personally use, I created another file and reference that first.
# That's why you'll see a fair bit of self-referencing examples, just change those or follow this format.
[ -f ${ENV_DIR}.secure.envs.sh ] && source ${ENV_DIR}.secure.envs.sh && echo "Sourced additional secure variables"

## PKS Related
export CLUSTER_NAME=${CLUSTER_NAME}

## General
# the base DNS name to build on top of, you should own this domain 
#   and have access to wildcard certificates for it
export BASE_DOMAIN=${BASE_DOMAIN}
# the DNS name of your PKS cluster
export PKS_HOSTNAME=${PKS_HOSTNAME}


# full URL for UAA, should be okay to let it derive it.
export UAA_URL=https://${PKS_HOSTNAME}:8443

# PKS UAA Admin Client Secret, get this from Ops Manager Credentials: Pks Uaa Management Admin Client
export PKS_ADMIN_CLIENT_SECRET=${PKS_ADMIN_CLIENT_SECRET}

# Tillerless Helm
export HELM_HOST=:44134

# DNS domain for external-dns controller to manage
export EXTERNAL_DNS_DOMAIN="${BASE_DOMAIN}"

# k8s environment specific:
export STORAGE_CLASS_NAME="ebs"

export INGRESS_STATIC_IP="192.168.2.50"
export LOAD_BALANCER_IP_RANGE="192.168.2.50-192.168.2.54"

#! Minio Related
#############################
export MINIO_DNS=s3.${EXTERNAL_DNS_DOMAIN}

# This is a specific label in the format "pv: XXXX" that minio uses to find the PVC for storage
export MINIO_PVC_LABEL=minio-objects

## concourse
# The UAA/OIDC user to add to 'main' group in concourse.
export CONCOURSE_OIDC_USER=${CONCOURSE_OIDC_USER}
# hostname to register in DNS
export CONCOURSE_DNS=concourse.${EXTERNAL_DNS_DOMAIN}
# password for concourse admin user
export CONCOURSE_ADMIN_PASSWORD=${CONCOURSE_ADMIN_PASSWORD}
# client id and secret for concourse to auth against UAA
export CONCOURSE_OIDC_CLIENT_ID=${CONCOURSE_OIDC_CLIENT_ID}
export CONCOURSE_OIDC_CLIENT_SECRET=${CONCOURSE_OIDC_CLIENT_SECRET}

export CONCOURSE_POSTGRES_ADMIN_PASSWORD=${CONCOURSE_POSTGRES_ADMIN_PASSWORD}

export CONCOURSE_HOST_KEY_PRIVATE=${CONCOURSE_HOST_KEY_PRIVATE}
export CONCOURSE_HOST_KEY_PUB=${CONCOURSE_HOST_KEY_PUB}
export CONCOURSE_SESSION_KEY_PRIVATE=${CONCOURSE_SESSION_KEY_PRIVATE}
export CONCOURSE_WORKER_KEY_PRIVATE=${CONCOURSE_WORKER_KEY_PRIVATE}
export CONCOURSE_WORKER_KEY_PUB=${CONCOURSE_WORKER_KEY_PUB}

#! Grafana Related
#############################
# hostname to register in DNS
export GRAFANA_DNS=grafana.${EXTERNAL_DNS_DOMAIN}
# password for concourse admin user
export GRAFANA_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
# client id and secret for concourse to auth against UAA
export GRAFANA_OIDC_CLIENT_ID=grafana_client
export GRAFANA_OIDC_CLIENT_SECRET=${GRAFANA_OIDC_CLIENT_SECRET} #CHANGEME

## harbor
# hostname to register in DNS
export HARBOR_DNS=harbor.${EXTERNAL_DNS_DOMAIN}
export HARBOR_NOTARY_DNS=notary.${EXTERNAL_DNS_DOMAIN}

# A bunch of passwords and secrets that you should change
export HARBOR_ADMIN_PASSWORD=${HARBOR_ADMIN_PASSWORD}
export HARBOR_SECRET_KEY=${HARBOR_SECRET_KEY}
export HARBOR_DATABASE_PASSWORD=${HARBOR_DATABASE_PASSWORD}
export HARBOR_INTERNAL_SECRET=${HARBOR_INTERNAL_SECRET}
# UAA/OIDC client id/secret to use to auth against UAA
export HARBOR_UAA_CLIENT_ID=${HARBOR_UAA_CLIENT_ID}
export HARBOR_UAA_CLIENT_SECRET=${HARBOR_UAA_CLIENT_SECRET}

## GitLab
##############################

export GITLAB_DNS=gitlab.${EXTERNAL_DNS_DOMAIN}

export GITLAB_RUNNER_REGISTRATION_TOKEN=${GITLAB_RUNNER_REGISTRATION_TOKEN}

export GITLAB_UAA_CLIENT_ID=${GITLAB_UAA_CLIENT_ID}
export GITLAB_UAA_CLIENT_SECRET=${GITLAB_UAA_CLIENT_SECRET}

export GITLAB_POSTGRESQL_PASSWORD=${GITLAB_POSTGRESQL_PASSWORD}

## Unifi SNMP
###################################################

export SNMP_AUTH_USERNAME=${SNMP_AUTH_USERNAME}
export SNMP_AUTH_PASSWORD=${SNMP_AUTH_PASSWORD}


## Microsoft SQL Server
###################################################

export MSSQL_PASSWORD=${MSSQL_PASSWORD}

export SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}


## RabbitMQ
###################################################

export RABBITMQ_DNS=rabbit.${EXTERNAL_DNS_DOMAIN}

export RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}
export RABBITMQ_ERLANGCOOKIE=${RABBITMQ_ERLANGCOOKIE}