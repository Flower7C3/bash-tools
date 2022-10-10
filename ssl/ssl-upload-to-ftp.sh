#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../vendor/Flower7C3/bash-helpers/_base.sh


## WELCOME
program_title "OpenSSL domain check"


## VARIABLES
prompt_variable_not_null domain_name "Domain name" "" 1 "$@"
prompt_variable_fixed dry_run "Dry run" "y" "y n" 2 "$@"
dry_run=y
user=$(id -u)
group=$(id -g)
source "$(dirname ${BASH_SOURCE})/config/_certbot.${domain_name}.sh"
printf "${COLOR_INFO_B}Please enter Your root password.${COLOR_INFO} \n"
sudo echo ""


## PROGRAM
printf "${COLOR_INFO_B}Żądanie SSL${COLOR_INFO} \n"
sudo cat ${CERTBOT_DATA_DIR_PATH}csr/0000_csr-certbot.pem
if [[ "$dry_run" == "n" ]]; then
	# ftp_remove "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.csr"
	sudo cp -f ${CERTBOT_DATA_DIR_PATH}csr/0000_csr-certbot.pem ${domain_name}.csr
	sudo chown ${user}:${group} ${domain_name}.csr
	chmod 644 ${domain_name}.csr
	ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.csr"
	sudo rm ${domain_name}.csr
fi
echo ""

printf "${COLOR_INFO_B}Certyfikat SSL${COLOR_INFO} \n"
sudo cat ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/cert.pem
if [[ "$dry_run" == "n" ]]; then
	# ftp_remove "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.crt"
	sudo cp -f ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/cert.pem ${domain_name}.crt
	sudo chown ${user}:${group} ${domain_name}.crt
	chmod 644 ${domain_name}.crt
	ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.crt"
	sudo rm ${domain_name}.crt
fi
echo ""

printf "${COLOR_INFO_B}Klucz SSL${COLOR_INFO} \n"
sudo cat ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/privkey.pem
if [[ "$dry_run" == "n" ]]; then
	# ftp_remove "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.key"
	sudo cp -f ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/privkey.pem ${domain_name}.key
	sudo chown ${user}:${group} ${domain_name}.key
	chmod 400 ${domain_name}.key
	ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.key"
	sudo rm ${domain_name}.key
fi
echo ""

printf "${COLOR_INFO_B}Paczka SSL${COLOR_INFO} \n"
sudo cat ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/chain.pem
if [[ "$dry_run" == "n" ]]; then
	# ftp_remove "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.bundle"
	sudo cp -f ${CERTBOT_DATA_DIR_PATH}live/${domain_name}/chain.pem ${domain_name}.bundle
	sudo chown ${user}:${group} ${domain_name}.bundle
	chmod 644 ${domain_name}.bundle
	ftp_upload "${FTP_HOST}" "${FTP_USER}" "${FTP_PASS}" "${FTP_SSL_PATH}" "${domain_name}.bundle"
	sudo rm ${domain_name}.bundle
fi
echo ""

print_new_line
