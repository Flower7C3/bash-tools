#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh
source "$(dirname ${BASH_SOURCE})/config/_certbot.${CERTBOT_DOMAIN}.sh"


## WELCOME
echo "Remove ${FTP_USER}@${FTP_USER}${FTP_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN} file"

ftp_remove "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_DOMAIN_PATH}${ACME_PATH}" "${CERTBOT_TOKEN}"
rm ${CERTBOT_TOKEN}
