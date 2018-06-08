#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "Update SSL for domain"


## VARIABLES
certbot_manual_auth_script_hook_path="$(dirname ${BASH_SOURCE})/ssl-hook-ftp-auth.sh"
certbot_manual_cleanup_script_hook_path="$(dirname ${BASH_SOURCE})/ssl-hook-ftp-cleanup.sh"
ssl_ftp_upload_script_path="$(dirname ${BASH_SOURCE})/ssl-upload-to-ftp.sh"
ssl_check_script_path="$(dirname ${BASH_SOURCE})/ssl-check.sh"
prompt_variable_not_null domain_name "Domain name" "" 1 "$@"
domain_config_file_path="$(dirname ${BASH_SOURCE})/config/_certbot.${domain_name}.sh"
prompt_variable_fixed dry_run "Dry run" "y" "y n" 2 "$@"
if [[ ! -f "$domain_config_file_path" ]]; then
    display_error "There is not config file ${domain_name} domain"
    confirm_or_exit "Do you wan to generate config file for ${color_question_h}${domain_name}${color_question} domain?"
    prompt_variable_not_null KEY_SIZE "SSL key size" "4096"
    prompt_variable_not_null ACME_PATH "Acme well known challenge path" ".well-known/acme-challenge/"
    prompt_variable_not_null DOMAIN_EMAIL "Domain email" ""
    prompt_variable_not_null FTP_HOST "FTP host name" ""
    prompt_variable_not_null FTP_USER "FTP user name" ""
    prompt_password FTP_PASS "FTP password" ""
    prompt_variable_not_null FTP_DOMAIN_PATH "FTP domain root path" "/public_html/"
    prompt_variable FTP_SSL_PATH "FTP SSL store path" ""
    confirm_or_exit "Save above data to ${color_question_h}${domain_config_file_path}${color_question} config file?"
    touch ${domain_config_file_path}
    echo 'CERTBOT_BINARIES_DIR_PATH="$(dirname ${BASH_SOURCE})/../vendor/certbot/"' >> ${domain_config_file_path}
    echo 'CERTBOT_DATA_DIR_PATH="$(dirname ${BASH_SOURCE})/../data/"' >> ${domain_config_file_path}
    echo 'KEY_SIZE='"'${KEY_SIZE}'" >> ${domain_config_file_path}
    echo 'ACME_PATH='"'${ACME_PATH}'" >> ${domain_config_file_path}
    echo 'DOMAIN_EMAIL='"'${DOMAIN_EMAIL}'" >> ${domain_config_file_path}
    echo 'DOMAIN_NAME='"'${DOMAIN_NAME}'" >> ${domain_config_file_path}
    echo 'FTP_HOST='"'${FTP_HOST}'" >> ${domain_config_file_path}
    echo 'FTP_USER='"'${FTP_USER}'" >> ${domain_config_file_path}
    echo 'FTP_PASS='"'${FTP_PASS}'" >> ${domain_config_file_path}
    echo 'FTP_DOMAIN_PATH='"'${FTP_DOMAIN_PATH}'" >> ${domain_config_file_path}
    echo 'FTP_SSL_PATH='"'${FTP_SSL_PATH}'" >> ${domain_config_file_path}
printf "${color_info_b}File saved!${color_info} \n"
fi
source "$domain_config_file_path"
printf "${color_log_b}Please enter Your root password.${color_log} \n"
sudo echo ""


## PROGRAM
if [[ "$dry_run" == "n" ]]; then

    if [ ! -d "$CERTBOT_BINARIES_DIR_PATH" ]; then
        printf "${color_info_b}Get certbot from GitHub${color_info} \n"
    	git clone https://github.com/certbot/certbot ${CERTBOT_BINARIES_DIR_PATH}
    fi

    printf "${color_info_b}Get info about certificate${color_info} \n"
    ${CERTBOT_BINARIES_DIR_PATH}certbot-auto certificates \
        --config-dir ${CERTBOT_DATA_DIR_PATH} \
        --email ${DOMAIN_EMAIL} \
        -d ${domain_name} -d www.${domain_name}

    printf "${color_info_b}Update certificate${color_info} \n"
    ${CERTBOT_BINARIES_DIR_PATH}certbot-auto certonly \
        -a manual \
        --config-dir ${CERTBOT_DATA_DIR_PATH} \
        --email ${DOMAIN_EMAIL} \
        -d ${domain_name} -d www.${domain_name} \
        --rsa-key-size ${KEY_SIZE} \
        --manual-auth-hook ${certbot_manual_auth_script_hook_path} \
        --manual-cleanup-hook ${certbot_manual_cleanup_script_hook_path}

fi

bash ${ssl_ftp_upload_script_path} ${domain_name} ${dry_run}
bash ${ssl_check_script_path} ${domain_name}
bash ${ssl_check_script_path} www.${domain_name}

program_end
