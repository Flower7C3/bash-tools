#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
_proxy_host="example-proxy-dev"
_remote_host="example-server-dev"
_directory="dev"
_mongo_host="mongo3"
_database="example"

## WELCOME
program_title "Mongo dump-n-import: from remote Symfony app via proxy to local/docker"

## VARIABLES
prompt_variable proxy_host "Proxy name (from SSH config file)" "$_proxy_host" 1 "$@"
prompt_variable remote_host "Remote host name (from SSH config file)" "$_remote_host" 2 "$@"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 3 "$@"
export_dir_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S")"
export_file_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S").tar.gz"
remote_data_dir_path='${HOME}/backup/'
prompt_variable mongo_host "Local Mongo machine name (or Docker container name)" "$_mongo_host" 4 "$@"
if [ "$_mongo_host" == "localhost" ]; then
    _is_docker=false
    prompt_variable database "Local Mongo database name" "$_database" 5 "$@"
    local_data_dir_path="${HOME}/backup/"
else
    _is_docker=true
    prompt_variable database "Docker Mongo database name" "$_database" 5 "$@"
    local_data_dir_path="${HOME}/www/database/mongo/${mongo_host}/data/"
fi

## PROGRAM
confirm_or_exit "Dump Mongo on ${COLOR_QUESTION_H}${remote_host}${COLOR_QUESTION} host via ${COLOR_QUESTION_H}${proxy_host}${COLOR_QUESTION} host from directory ${COLOR_QUESTION_H}${directory}${COLOR_QUESTION} and save on local/docker ${COLOR_QUESTION_H}${mongo_host}${COLOR_QUESTION} container to ${COLOR_QUESTION_H}${database}${COLOR_QUESTION} database?"

sourced_scripts_list+=('mongo-dump-symfony.sh mongo-dump-symfony.sh' 'mongo-dump-remote-symfony.sh mongo-dump-remote-symfony.sh')
copy_scripts_to_host "$proxy_host"

ssh ${proxy_host} 'yes | bash ${HOME}/mongo-dump-remote-symfony.sh '${remote_host}' '${directory}' '${export_dir_name}' '${export_file_name}

move_file_from_host_to_local "$proxy_host" "$remote_data_dir_path" "$local_data_dir_path" "$export_file_name"

remove_scripts_from_host "$proxy_host"

if [ "$_is_docker" == "true" ]; then
    yes | bash $(dirname ${BASH_SOURCE})/mongo-import-docker.sh "$mongo_host" "$database" "${export_dir_name}" "$export_file_name"
else
    yes | bash $(dirname ${BASH_SOURCE})/mongo-import-local.sh "$mongo_host" "$database" "${export_dir_name}" "$export_file_name"
fi

print_new_line
