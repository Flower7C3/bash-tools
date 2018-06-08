#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "OpenSSL domain check"


## VARIABLES
prompt_variable domain_name "Domain name" "" 1 "$@"


## PROGRAM
printf "${color_info_b}Check ${color_info_bi}%s${color_info_b} domain${color_info} \n" "$domain_name"
#openssl s_client -showcerts -connect ${domain_name}:443
echo | openssl s_client -servername ${domain_name} -connect ${domain_name}:443 2>/dev/null | openssl x509 -noout -dates

program_end
