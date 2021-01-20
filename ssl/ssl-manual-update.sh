#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_base.sh

## WELCOME
program_title "Update SSL for domain"


## VARIABLES
ssl_check_script_path="$(dirname ${BASH_SOURCE})/ssl-check.sh"
prompt_variable_not_null domain_name "Domain name" "" 1 "$@"
domain_config_file_path="$(dirname ${BASH_SOURCE})/config/_certbot.${domain_name}.sh"
prompt_variable_fixed staging_env "Staging ENV" "n" "y n" 2 "$@"
prompt_variable_fixed dry_run "Dry run" "y" "y n" 3 "$@"
prompt_variable_fixed preferred_challenges "Preffered challenge" "http" "http dns" 4 "$@"
prompt_variable_fixed challenge_protocol "Preffered challenge" "ftp" "ftp ssh" 5 "$@"
if [[ ! -f "$domain_config_file_path" ]]; then
    display_error "There is not config file ${domain_name} domain"
    confirm_or_exit "Do you wan to generate config file for ${COLOR_QUESTION_H}${domain_name}${COLOR_QUESTION} domain?"
    prompt_variable_not_null DOMAIN_NAMES "All domain names (separated with space)" "${domain_name}"
    prompt_variable_not_null KEY_SIZE "SSL key size" "4096"
    prompt_variable_not_null ACME_PATH "Acme well known challenge path" ".well-known/acme-challenge/"
    prompt_variable_not_null DOMAIN_EMAIL "Domain email" "$(whoami)@$(uname -n)"
    if [[ "$challenge_protocol" == "ftp" ]]; then
        prompt_variable_not_null FTP_HOST "FTP host name" ""
        prompt_variable_not_null FTP_USER "FTP user name" ""
        prompt_password FTP_PASS "FTP password" ""
        prompt_variable_not_null FTP_DOMAIN_PATH "FTP domain root path" "/public_html/"
        prompt_variable FTP_SSL_PATH "FTP SSL store path" ""
    fi
    if [[ "$challenge_protocol" == "ssh" ]]; then
        prompt_variable_not_null SSH_HOST "SSH host name" ""
        prompt_variable_not_null SSH_USER "SSH user name" ""
        prompt_password SSH_PORT "SSH port" ""
        prompt_variable_not_null SSH_DOMAIN_PATH "SSH domain root path" "/public_html/"
        prompt_variable SSH_SSL_PATH "SSH SSL store path" ""
    fi
    confirm_or_exit "Save above data to ${COLOR_QUESTION_H}${domain_config_file_path}${COLOR_QUESTION} config file?"
    touch ${domain_config_file_path}
    echo 'CERTBOT_BINARIES_DIR_PATH="$(dirname ${BASH_SOURCE})/../vendor/certbot/"' >> ${domain_config_file_path}
    echo 'CERTBOT_DATA_DIR_PATH="$(dirname ${BASH_SOURCE})/../data/"' >> ${domain_config_file_path}
    echo 'KEY_SIZE='"'${KEY_SIZE}'" >> ${domain_config_file_path}
    echo 'ACME_PATH='"'${ACME_PATH}'" >> ${domain_config_file_path}
    echo 'DOMAIN_EMAIL='"'${DOMAIN_EMAIL}'" >> ${domain_config_file_path}
    echo 'DOMAIN_NAME='"'${DOMAIN_NAME}'" >> ${domain_config_file_path}
    echo 'DOMAIN_NAMES='"'${DOMAIN_NAMES}'" >> ${domain_config_file_path}
    if [[ "$challenge_protocol" == "ftp" ]]; then
        echo 'FTP_HOST='"'${FTP_HOST}'" >> ${domain_config_file_path}
        echo 'FTP_USER='"'${FTP_USER}'" >> ${domain_config_file_path}
        echo 'FTP_PASS='"'${FTP_PASS}'" >> ${domain_config_file_path}
        echo 'FTP_DOMAIN_PATH='"'${FTP_DOMAIN_PATH}'" >> ${domain_config_file_path}
        echo 'FTP_SSL_PATH='"'${FTP_SSL_PATH}'" >> ${domain_config_file_path}
    fi
    if [[ "$challenge_protocol" == "ssh" ]]; then
        echo 'SSH_HOST='"'${SSH_HOST}'" >> ${domain_config_file_path}
        echo 'SSH_USER='"'${SSH_USER}'" >> ${domain_config_file_path}
        echo 'SSH_PORT='"'${SSH_PORT}'" >> ${domain_config_file_path}
        echo 'SSH_DOMAIN_PATH='"'${SSH_DOMAIN_PATH}'" >> ${domain_config_file_path}
        echo 'SSH_SSL_PATH='"'${SSH_SSL_PATH}'" >> ${domain_config_file_path}
    fi
    printf "${COLOR_INFO_B}File saved!${COLOR_INFO} \n"
    DOMAIN_NAMES_ARR=($(echo $DOMAIN_NAMES))
    for _domain_name in "${DOMAIN_NAMES_ARR[@]}"; do
        _domain_config_file_path="${domain_config_file_path/${domain_name}/${_domain_name}}"
        ln -s ${domain_config_file_path} ${_domain_config_file_path}
    done
fi
source "$domain_config_file_path"
CERTBOT_AUTO_FILE_PATH="${CERTBOT_BINARIES_DIR_PATH}certbot-auto"
printf "${COLOR_LOG_B}Please enter Your root password.${COLOR_LOG} \n"
sudo echo ""

## PROGRAM

# rm ${CERTBOT_AUTO_FILE_PATH}
if [ ! -f "${CERTBOT_AUTO_FILE_PATH}" ]; then
    printf "${COLOR_INFO_B}Get certbot from GitHub${COLOR_INFO} \n"
	# git clone https://github.com/certbot/certbot ${CERTBOT_BINARIES_DIR_PATH}
    mkdir -p ${CERTBOT_BINARIES_DIR_PATH}
    curl --output ${CERTBOT_AUTO_FILE_PATH} https://dl.eff.org/certbot-auto
    chmod a+x ${CERTBOT_AUTO_FILE_PATH}
    # wget -N https://dl.eff.org/certbot-auto.asc
    # gpg2 --keyserver pool.sks-keyservers.net --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2
    # gpg2 --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc ${CERTBOT_AUTO_FILE_PATH}
    # rm certbot-auto.asc
fi

certificates_params=""
certonly_params=""
certificates_params="${certonly_params} --config-dir ${CERTBOT_DATA_DIR_PATH}"
certonly_params="${certonly_params} --config-dir ${CERTBOT_DATA_DIR_PATH}"
certificates_params="${certonly_params} --email ${DOMAIN_EMAIL}"
certonly_params="${certonly_params} --email ${DOMAIN_EMAIL}"
DOMAIN_NAMES_ARR=($(echo $DOMAIN_NAMES))
for _domain_name in "${DOMAIN_NAMES_ARR[@]}"; do
    certificates_params="${certonly_params} -d ${_domain_name}"
    certonly_params="${certonly_params} -d ${_domain_name}"
done
if [[ "$challenge_protocol" == "ftp" ]]; then
    certonly_params="${certonly_params} --manual-auth-hook $(dirname ${BASH_SOURCE})/ssl-hook-ftp-auth.sh"
    certonly_params="${certonly_params} --manual-cleanup-hook $(dirname ${BASH_SOURCE})/ssl-hook-ftp-cleanup.sh"
fi
if [[ "$challenge_protocol" == "ssh" ]]; then
    certonly_params="${certonly_params} --manual-auth-hook $(dirname ${BASH_SOURCE})/ssl-hook-ssh-auth.sh"
    certonly_params="${certonly_params} --manual-cleanup-hook $(dirname ${BASH_SOURCE})/ssl-hook-ssh-cleanup.sh"
fi
certonly_params="${certonly_params} --preferred-challenges ${preferred_challenges}"
if [[ "$staging_env" == "y" ]]; then
    certonly_params="${certonly_params} --staging"
fi
if [[ "$dry_run" == "y" ]]; then
    certonly_params="${certonly_params} --dry-run"
fi
if [[ "$dry_run" == "y" ]]; then
    certonly_params="${certonly_params} --dry-run"
fi
certonly_params="${certonly_params} -a manual --manual-public-ip-logging-ok --rsa-key-size ${KEY_SIZE}"

# printf "${COLOR_INFO_B}Get info about certificate${COLOR_INFO} \n"
# ${CERTBOT_AUTO_FILE_PATH} certificates ${certificates_params}
# read -p "Press ENTER to continue..."

printf "${COLOR_INFO_B}Update certificate${COLOR_INFO} \n"
${CERTBOT_AUTO_FILE_PATH} certonly ${certonly_params}
read -p "Press ENTER to continue..."

if [[ "$challenge_protocol" == "ftp" ]]; then
    ssl_ftp_upload_script_path="$(dirname ${BASH_SOURCE})/ssl-upload-to-ftp.sh"
    bash ${ssl_ftp_upload_script_path} ${domain_name} ${dry_run}
fi
bash ${ssl_check_script_path} ${domain_name}

print_new_line
