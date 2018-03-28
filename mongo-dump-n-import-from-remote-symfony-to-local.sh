#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_remote_host="example-server-dev"
_directory="dev"
_mongo_host="mongo3"
_database="example"


## WELCOME
program_title "Mongo dump-n-import: from remote Symfony app to local/docker"


## VARIABLES
prompt_variable remote_host "Remote host name (from SSH config file)" "$_remote_host" 1 "$@"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 2 "$@"
export_dir_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S")"
export_file_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S").tar.gz"
remote_data_dir_path='${HOME}/backup/'
prompt_variable mongo_host "Local Mongo machine name (or Docker container name)" "$_mongo_host" 3 "$@"
if [ "$_mongo_host" == "localhost" ]; then
	_is_docker=false
	_mongo_host_type="host"
	prompt_variable database "Local Mongo database name" "$_database" 4 "$@"
	local_data_dir_path="${HOME}/backup/"
else
	_is_docker=true
	_mongo_host_type="docker container"
	prompt_variable database "Docker Mongo database name" "$_database" 4 "$@"
	local_data_dir_path="${HOME}/www/database/mongo/${mongo_host}/data/"
fi


## PROGRAM
confirm_or_exit "Dump Mongo on ${color_question_h}${remote_host}${color_question} host from directory ${color_question_h}${directory}${color_question} and save on ${color_question_h}${mongo_host}${color_question} ${_mongo_host_type} to ${color_question_h}${database}${color_question} database?"

sourced_scripts_list+=('mongo-dump-symfony.sh mongo-dump-symfony.sh')
copy_scripts_to_host "$remote_host"

ssh ${remote_host} 'yes | bash ${HOME}/mongo-dump-symfony.sh '${directory}' '${export_dir_name}' '${export_file_name} 0

move_file_from_host_to_local "$remote_host" "$remote_data_dir_path" "$local_data_dir_path" "$export_file_name"

remove_scripts_from_host "$remote_host"

if [ "$_is_docker" == "true" ]; then
	yes | bash $(dirname ${BASH_SOURCE})/mongo-import-docker.sh "$mongo_host" "$database" "${export_dir_name}" "$export_file_name"
else
	yes | bash $(dirname ${BASH_SOURCE})/mongo-import-local.sh "$mongo_host" "$database" "${export_dir_name}" "$export_file_name"
fi

program_end
