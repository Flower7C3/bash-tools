###############################################################
### Scripts
###############################################################

function copy_scripts_to_host() {
    local host=$1
    printf "${color_success_b}Copy scripts to ${color_success_h}${host}${color_success_b} host ${color_success} \n"
    for i in "${!sourced_scripts_list[@]}"; do
        file_info=(${sourced_scripts_list[$i]})
        local_file_name=${file_info[0]}
        file_nameRemote=${file_info[1]}
        scp ${base_dir_path}${local_file_name} ${host}:'${HOME}/'${file_nameRemote}
    done
    printf "${color_off}"
}

function remove_scripts_from_host() {
    local host=$1
    printf "${color_error_b}Cleanup scripts on ${color_error_h}${host}${color_error_b} host ${color_error} \n"
    for i in "${!sourced_scripts_list[@]}"; do
        file_info=(${sourced_scripts_list[$i]})
        file_nameRemote=${file_info[1]}
        ssh ${host} 'rm ${HOME}/'${file_nameRemote}
    done
    printf "${color_off}"
}

###############################################################
### File operations over SSH
###############################################################

function copy_file_between_hosts() {
    local sourceHost=$1
    local destHost=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${color_success_b}Copy ${color_success_h}${file_name}${color_success_b} file from ${color_success_h}${sourceHost}${color_success_b} host to ${color_success_h}local${color_success_b} host${color_success} \n"
    scp $sourceHost:$file_name $file_name

    printf "${color_success_b}Copy ${color_success_h}${file_name}${color_success_b} file from ${color_success_h}local${color_success_b} host to ${color_success_h}${destHost}${color_success_b} host${color_success} \n"
    scp $file_name $destHost:$file_name
}

function remove_file_from_hosts() {
    local sourceHost=$1
    local destHost=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${color_error_b}Remove ${color_error_h}${file_name}${color_error_b} file from ${color_error_h}${sourceHost}${color_error_b} host, ${color_error_h}${destHost}${color_error_b} host and ${color_error_h}local${color_error_b} host${color_error} \n"
    ssh $sourceHost 'rm -rf '${file_name}''
    ssh $destHost 'rm -rf '${file_name}''
    rm -rf $file_name
}

###############################################################
### Copy / move / remove on remote host
###############################################################

function copy_file_from_host_to_local() {
    local host=$1
    local remote_data_dir_path=$2
    local local_data_dir_path=$3
    local file_name=$4
    printf "${color_success_b}Copy ${color_success_h}${file_name}${color_success_b} from ${color_success_h}${host}${color_success_b} host to ${color_success_h}local${color_success_b} host ${color_success} \n"
    mkdir -p ${local_data_dir_path}
    scp ${host}:${remote_data_dir_path}${file_name} ${local_data_dir_path}${file_name}
    printf "${color_off}"
}

function remove_file_from_host() {
    local host=$1
    local remote_data_dir_path=$2
    local file_name=$3
    if [[ -n "$remote_data_dir_path" && -n "$file_name" ]]; then
        printf "${color_error_b}Remove ${color_error_h}${file_name}${color_error_b} file from ${color_error_h}${host}${color_error_b} host ${color_error} \n"
        ssh ${host} 'rm '${remote_data_dir_path}${file_name}
        printf "${color_off}"
    fi
}

function move_file_from_host_to_local() {
    local host=$1
    local remote_data_dir_path=$2
    local local_data_dir_path=$3
    local file_name=$4
    copy_file_from_host_to_local "$host" "$remote_data_dir_path" "$local_data_dir_path" "$file_name"
    remove_file_from_host "$host" "$remote_data_dir_path" "$file_name"
}

###############################################################
### Remove on local host
###############################################################

function remove_file_from_local() {
    local local_data_dir_path=$1
    local file_name=$2

    if [[ -n "$local_data_dir_path" && -n "$file_name" && -f "${local_data_dir_path}${file_name}" ]]; then
        printf "${color_error_b}Remove ${color_error_h}${file_name}${color_error_b} file from local ${color_error} \n"
        rm ${local_data_dir_path}${file_name}
        printf "${color_off}"
    fi
}

function remove_dir_from_local() {
    local local_data_dir_path=$1
    local dir_name=$2

    if [[ -n "$local_data_dir_path" && -n "$dir_name" && -d "${local_data_dir_path}${dir_name}" ]]; then
        printf "${color_error_b}Remove ${color_error_h}${dir_name}${color_error_b} directory from local ${color_error} \n"
        rm -rf ${local_data_dir_path}${dir_name}
        printf "${color_off}"
    fi
}
