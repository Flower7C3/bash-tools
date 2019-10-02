#!/usr/bin/env bash

env > /tmp/cleanup_env_vars

source $(dirname ${BASH_SOURCE})/_base.sh
source "$(dirname ${BASH_SOURCE})/config/_certbot.${CERTBOT_DOMAIN}.sh"


## WELCOME
echo "Remove ${FTP_USER}@${FTP_USER}${FTP_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN} file"

ssh -p ${SSH_PORT} ${SSH_USER}@${SSH_HOST} "rm ${SSH_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN}"
rm ${CERTBOT_TOKEN}
