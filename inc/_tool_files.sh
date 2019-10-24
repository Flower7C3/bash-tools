###############################################################
### Scripts
###############################################################

function copy_scripts_to_host() {
    local host=$1
    printf "${COLOR_SUCCESS_B}Copy scripts to ${COLOR_SUCCESS_H}${host}${COLOR_SUCCESS_B} host ${COLOR_SUCCESS} \n"
    for i in "${!sourced_scripts_list[@]}"; do
        file_info=(${sourced_scripts_list[$i]})
        local_file_name=${file_info[0]}
        file_nameRemote=${file_info[1]}
        scp ${base_dir_path}${local_file_name} ${host}:'${HOME}/'${file_nameRemote}
    done
    color_reset
}

function remove_scripts_from_host() {
    local host=$1
    printf "${COLOR_ERROR_B}Cleanup scripts on ${COLOR_ERROR_H}${host}${COLOR_ERROR_B} host ${COLOR_ERROR} \n"
    for i in "${!sourced_scripts_list[@]}"; do
        file_info=(${sourced_scripts_list[$i]})
        file_nameRemote=${file_info[1]}
        ssh ${host} 'rm ${HOME}/'${file_nameRemote}
    done
    color_reset
}

###############################################################
### File operations over SSH
###############################################################

function copy_file_between_hosts() {
    local sourceHost=$1
    local destHost=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${COLOR_SUCCESS_B}Copy ${COLOR_SUCCESS_H}${file_name}${COLOR_SUCCESS_B} file from ${COLOR_SUCCESS_H}${sourceHost}${COLOR_SUCCESS_B} host to ${COLOR_SUCCESS_H}local${COLOR_SUCCESS_B} host${COLOR_SUCCESS} \n"
    scp $sourceHost:$file_name $file_name

    printf "${COLOR_SUCCESS_B}Copy ${COLOR_SUCCESS_H}${file_name}${COLOR_SUCCESS_B} file from ${COLOR_SUCCESS_H}local${COLOR_SUCCESS_B} host to ${COLOR_SUCCESS_H}${destHost}${COLOR_SUCCESS_B} host${COLOR_SUCCESS} \n"
    scp $file_name $destHost:$file_name
}

function remove_file_from_hosts() {
    local sourceHost=$1
    local destHost=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${COLOR_ERROR_B}Remove ${COLOR_ERROR_H}${file_name}${COLOR_ERROR_B} file from ${COLOR_ERROR_H}${sourceHost}${COLOR_ERROR_B} host, ${COLOR_ERROR_H}${destHost}${COLOR_ERROR_B} host and ${COLOR_ERROR_H}local${COLOR_ERROR_B} host${COLOR_ERROR} \n"
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
    printf "${COLOR_SUCCESS_B}Copy ${COLOR_SUCCESS_H}${file_name}${COLOR_SUCCESS_B} from ${COLOR_SUCCESS_H}${host}${COLOR_SUCCESS_B} host to ${COLOR_SUCCESS_H}local${COLOR_SUCCESS_B} host ${COLOR_SUCCESS} \n"
    mkdir -p ${local_data_dir_path}
    scp ${host}:${remote_data_dir_path}${file_name} ${local_data_dir_path}${file_name}
    color_reset
}

function remove_file_from_host() {
    local host=$1
    local remote_data_dir_path=$2
    local file_name=$3
    if [[ -n "$remote_data_dir_path" && -n "$file_name" ]]; then
        printf "${COLOR_ERROR_B}Remove ${COLOR_ERROR_H}${file_name}${COLOR_ERROR_B} file from ${COLOR_ERROR_H}${host}${COLOR_ERROR_B} host ${COLOR_ERROR} \n"
        ssh ${host} 'rm '${remote_data_dir_path}${file_name}
        color_reset
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
        printf "${COLOR_ERROR_B}Remove ${COLOR_ERROR_H}${file_name}${COLOR_ERROR_B} file from local ${COLOR_ERROR} \n"
        rm ${local_data_dir_path}${file_name}
        color_reset
    fi
}

function remove_dir_from_local() {
    local local_data_dir_path=$1
    local dir_name=$2

    if [[ -n "$local_data_dir_path" && -n "$dir_name" && -d "${local_data_dir_path}${dir_name}" ]]; then
        printf "${COLOR_ERROR_B}Remove ${COLOR_ERROR_H}${dir_name}${COLOR_ERROR_B} directory from local ${COLOR_ERROR} \n"
        rm -rf ${local_data_dir_path}${dir_name}
        color_reset
    fi
}
