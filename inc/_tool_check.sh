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
    printf "${color_info_b}%16s ${color_info_h}%60s${color_info_b}\t${color_log_h}%s${color_info_b}\n${color_log}" "SSH" "${username}@${hostname}" "$sshStatus"
}

function domain_status_code_check() {
    local domain=$1
    local userpass=$2
    local statusCode=$(curl -H "Cache-Control: no-cache" -L -u "${userpass}" -s -o /dev/null -I -w "%{http_code}" ${domain})
    printf "${color_info_b}%16s ${color_info_h}%60s${color_info_b}\t" "DOMENA" "$domain"
    if (("$statusCode" >= 200 && "$statusCode" < 400)); then
        printf "${color_success_h}"
    else
        if (("$statusCode" >= 400 && "$statusCode" < 600)); then
            printf "${color_error_h}"
        else
            printf "${color_log_h}"
        fi
    fi
    printf "%s\n${color_log}" $statusCode
}

function domain_status_code_check_or_rollback() {
    local url=${1:-http://localhost/}

    local exists=$(curl -k -s --head ${url} | head -n 1 | grep "HTTP/1.[01] [23]..")

    if [ "$exists" == "" ]; then

        printf "${color_error_b}Site url ${color_error_h}${url}${color_error_b} is not working."
        if [[ "$current_commit_id" != "" ]]; then
            printf "${color_info}Check ${color_info_u}${color_info_b}a${color_info}gain or ${color_info_u}r${color_info}ollback or ${color_info_u}s${color_info}kip? \n"
        else
            printf "${color_info}Check ${color_info_u}${color_info_b}a${color_info}gain or ${color_info_u}s${color_info}kip? \n"
        fi
        printf "${color_notice_b} > ${color_notice}"
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
        printf "${color_success_b}Site url ${color_success_h}${url}${color_success_b} is working ${color_success} \n"
    fi
}
