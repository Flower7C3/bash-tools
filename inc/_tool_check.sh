###############################################################
### File check
###############################################################
function file_name_check() {
    local file_name=$1
    if [ -z "$file_name" ]; then
        display_error "File name not specified!"
        program_error
    fi
    file_name_test_1=$(printf ${file_name} | egrep "/")
    if [ -n "$file_name_test_1" ]; then
        display_error "File name is wrong!"
        program_error
    fi
}

function dir_name_check() {
    local dir_name=$1
    if [ -z "$dir_name" ]; then
        display_error "Dir name not specified!"
        program_error
    fi
    output_dir_test_1=$(printf ${dir_name} | egrep "/$")
    if [ -z "$output_dir_test_1" ]; then
        display_error "Dir name must end with slash!"
        program_error
    fi
}

###############################################################
### Domain check
###############################################################
function ssh_check() {
    local username=$1
    local hostname=$2
    local keyfile=$3
    sshStatus=$(ssh -i ${keyfile} -l ${username} ${hostname} "pwd")
    printf "${COLOR_INFO_B}%16s ${COLOR_INFO_H}%60s${COLOR_INFO_B}\t${COLOR_LOG_H}%s${COLOR_INFO_B}\n${COLOR_LOG}" "SSH" "${username}@${hostname}" "$sshStatus"
}

function domain_status_code_check() {
    local domain=$1
    local userpass=$2
    local statusCode=$(curl -H "Cache-Control: no-cache" -L -u "${userpass}" -s -o /dev/null -I -w "%{http_code}" ${domain})
    printf "${COLOR_INFO_B}%16s ${COLOR_INFO_H}%60s${COLOR_INFO_B}\t" "DOMENA" "$domain"
    if (("$statusCode" >= 200 && "$statusCode" < 400)); then
        printf "${COLOR_SUCCESS_H}"
    else
        if (("$statusCode" >= 400 && "$statusCode" < 600)); then
            printf "${COLOR_ERROR_H}"
        else
            printf "${COLOR_LOG_H}"
        fi
    fi
    printf "%s\n${COLOR_LOG}" $statusCode
}

function domain_status_code_check_or_rollback() {
    local url=${1:-http://localhost/}

    local exists=$(curl -k -s --head ${url} | head -n 1 | grep "HTTP/1.[01] [23]..")

    if [ "$exists" == "" ]; then

        printf "${COLOR_ERROR_B}Site url ${COLOR_ERROR_H}${url}${COLOR_ERROR_B} is not working."
        if [[ "$current_commit_id" != "" ]]; then
            printf "${COLOR_INFO}Check ${COLOR_INFO_U}${COLOR_INFO_B}a${COLOR_INFO}gain or ${COLOR_INFO_U}r${COLOR_INFO}ollback or ${COLOR_INFO_U}s${COLOR_INFO}kip? \n"
        else
            printf "${COLOR_INFO}Check ${COLOR_INFO_U}${COLOR_INFO_B}a${COLOR_INFO}gain or ${COLOR_INFO_U}s${COLOR_INFO}kip? \n"
        fi
        printf "${COLOR_NOTICE_B} > ${COLOR_NOTICE}"
        read -e input

        if [[ "$input" != "s" ]]; then
            if [[ "$current_commit_id" != "" ]]; then
                if [[ "$input" == "r" ]]; then
                    git_checkout ${current_commit_id}
                else
                    domain_status_code_check ${url}
                fi
            else
                domain_status_code_check ${url}
            fi
        fi

    else
        printf "${COLOR_SUCCESS_B}Site url ${COLOR_SUCCESS_H}${url}${COLOR_SUCCESS_B} is working ${COLOR_SUCCESS} \n"
    fi
}
