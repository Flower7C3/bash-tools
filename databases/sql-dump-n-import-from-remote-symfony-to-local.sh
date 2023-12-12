#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
_remote_host="example-server-dev"
_directory="dev"
_sql_host="mysql55"
_database="example"

## WELCOME
program_title "SQL dump-n-import: from remote Symfony app to local/docker"

## VARIABLES
prompt_variable remote_host "Remote host name (from SSH config file)" "$_remote_host" 1 "$@"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 2 "$@"
datetime=$(date "+%Y%m%d-%H%M%S")
export_file_name="backup_${remote_host}_${datetime}.sql"
remote_data_dir_path='${HOME}/backup/'
prompt_variable sql_host "Local MySQL machine name (or Docker container name)" "$_sql_host" 3 "$@"
if [ "$_sql_host" == "localhost" ]; then
    _is_docker=false
    _mongo_host_type="host"
    prompt_variable database "Local MySQL database name" "$_database" 4 "$@"
    local_data_dir_path="${HOME}/backup/"
else
    _is_docker=true
    _mongo_host_type="docker container"
    prompt_variable database "Docker MySQL database name" "$_database" 4 "$@"
    local_data_dir_path="${HOME}/www/database/mysql/${sql_host}/data/"
fi

## PROGRAM
confirm_or_exit "Dump SQL on ${COLOR_QUESTION_H}${remote_host}${COLOR_QUESTION} host from directory ${COLOR_QUESTION_H}${directory}${COLOR_QUESTION} and save on ${COLOR_QUESTION_H}${sql_host}${COLOR_QUESTION} ${_mongo_host_type} to ${COLOR_QUESTION_H}${database}${COLOR_QUESTION} database?"

sourced_scripts_list+=('sql-dump-symfony.sh sql-dump-symfony.sh')
copy_scripts_to_host "$remote_host"

ssh ${remote_host} 'yes | bash ${HOME}/sql-dump-symfony.sh '${directory}' '${export_file_name} 0

move_file_from_host_to_local "$remote_host" "$remote_data_dir_path" "$local_data_dir_path" "$export_file_name"

remove_scripts_from_host "$remote_host"

if [ "$_is_docker" == "true" ]; then
    yes | bash $(dirname ${BASH_SOURCE})/sql-import-docker.sh "$sql_host" "$database" "$export_file_name"
else
    yes | bash $(dirname ${BASH_SOURCE})/sql-import-local.sh "$sql_host" "$database" "$export_file_name"
fi

print_new_line
