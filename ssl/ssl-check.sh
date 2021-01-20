#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_base.sh


## WELCOME
program_title "OpenSSL domain check"


## VARIABLES
prompt_variable domain_name "Domain name" "" 1 "$@"


## PROGRAM
printf "${COLOR_INFO_B}Check ${COLOR_INFO_BI}%s${COLOR_INFO_B} domain${COLOR_INFO} \n" "$domain_name"
#openssl s_client -showcerts -connect ${domain_name}:443
echo | openssl s_client -servername ${domain_name} -connect ${domain_name}:443 2>/dev/null | openssl x509 -noout -dates

print_new_line
