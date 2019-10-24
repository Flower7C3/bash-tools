#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_proxy_host="example-proxy-dev"
_remote_host="example-server-dev"
_directory="dev"
_sql_host="mysql55"
_database="example"


## WELCOME
program_title "SQL dump-n-import: from remote Symfony app via proxy to local/docker"


## VARIABLES
prompt_variable proxy_host "Proxy name (from SSH config file)" "$_proxy_host" 1 "$@"
prompt_variable remote_host "Remote host name (from SSH config file)" "$_remote_host" 2 "$@"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 3 "$@"
datetime=$(date "+%Y%m%d-%H%M%S")
export_file_name="backup_${remote_host}_${datetime}.sql"
remote_data_dir_path='${HOME}/backup/'
prompt_variable sql_host "Local MySQL machine name (or Docker container name)" "$_sql_host" 4 "$@"
if [ "$_sql_host" == "localhost" ]; then
	_is_docker=false
	prompt_variable database "Local MySQL database name" "$_database" 5 "$@"
	local_data_dir_path="${HOME}/backup/"
else
	_is_docker=true
	prompt_variable database "Docker MySQL database name" "$_database" 5 "$@"
	local_data_dir_path="${HOME}/www/database/mysql/${sql_host}/data/"
fi


## PROGRAM
confirm_or_exit "Dump SQL on ${COLOR_QUESTION_H}${remote_host}${COLOR_QUESTION} host via ${COLOR_QUESTION_H}${proxy_host}${COLOR_QUESTION} host from directory ${COLOR_QUESTION_H}${directory}${COLOR_QUESTION} and save on local/docker ${COLOR_QUESTION_H}${sql_host}${COLOR_QUESTION} container to ${COLOR_QUESTION_H}${database}${COLOR_QUESTION} database?"

sourced_scripts_list+=('sql-dump-symfony.sh sql-dump-symfony.sh' 'sql-dump-remote-symfony.sh sql-dump-remote-symfony.sh')
copy_scripts_to_host "$proxy_host"

ssh ${proxy_host} 'yes | bash ${HOME}/sql-dump-remote-symfony.sh '${remote_host}' '${directory}' '${export_file_name}

move_file_from_host_to_local "$proxy_host" "$remote_data_dir_path" "$local_data_dir_path" "$export_file_name"

remove_scripts_from_host "$proxy_host"

if [ "$_is_docker" == "true" ]; then
	yes | bash $(dirname ${BASH_SOURCE})/sql-import-docker.sh "$sql_host" "$database" "$export_file_name"
else
	yes | bash $(dirname ${BASH_SOURCE})/sql-import-local.sh "$sql_host" "$database" "$export_file_name"
fi

print_new_line
