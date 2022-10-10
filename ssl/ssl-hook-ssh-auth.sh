#!/usr/bin/env bash

env > /tmp/cleanup_env_vars

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh
source "$(dirname ${BASH_SOURCE})/config/_certbot.${CERTBOT_DOMAIN}.sh"


## WELCOME
echo "Create ${SSH_USER}@${SSH_USER}${SSH_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN} file"

echo ${CERTBOT_VALIDATION} > ${CERTBOT_TOKEN}
ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "mkdir -p ${SSH_DOMAIN_PATH}${ACME_PATH}"
scp -P ${SSH_PORT} ${CERTBOT_TOKEN} ${SSH_USER}@${SSH_HOST}:${SSH_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN}
read