#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh
source $(dirname ${BASH_SOURCE})/config/_certbot.${CERTBOT_DOMAIN}.sh


## WELCOME
program_title "Create ${FTP_USER}@${FTP_USER}${FTP_DOMAIN_PATH}${ACME_PATH}${CERTBOT_TOKEN} file"

echo ${CERTBOT_VALIDATION} > ${CERTBOT_TOKEN}
ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_DOMAIN_PATH}${ACME_PATH}" "${CERTBOT_TOKEN}"

program_end
