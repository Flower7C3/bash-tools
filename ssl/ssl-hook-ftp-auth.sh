#!/usr/bin/env bash

env >/tmp/cleanup_env_vars

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"
source "$(dirname "$BASH_SOURCE")/config/_certbot.${CERTBOT_DOMAIN}.sh"

## WELCOME
echo "Create ${FTP_USER}@${FTP_USER}${FTP_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN} file"

echo ${CERTBOT_VALIDATION} >${CERTBOT_TOKEN}
ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_DOMAIN_PATH}${ACME_PATH}" "${CERTBOT_TOKEN}"
