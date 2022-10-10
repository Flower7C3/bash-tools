#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh


## CONFIG
_docker_container_name="mysql55"
_database="example"
_export_file_name="backup_$(date "+%Y%m%d-%H%M%S").sql"


## WELCOME
program_title "SQL import to docker"


## VARIABLES
prompt_variable docker_container_name "Docker container name" "$_docker_container_name" 1 "$@"
prompt_variable database "Docker MySQL database name" "$_database" 2 "$@"

local_data_dir_path="${HOME}/www/database/mysql/${docker_container_name}/data/"
local_trigger_dir_path="${HOME}/www/database/mysql/${docker_container_name}/data/"
virtual_data_dir_path="/var/lib/mysql/"
virtual_trigger_dir_path="/var/lib/mysql/"
trigger_file_name=${database}".sql"

prompt_variable export_file_name "Export file name (from ${COLOR_QUESTION_H}${local_data_dir_path}${COLOR_QUESTION_B} directory)" "$_export_file_name" 3 "$@"


## PROGRAM
confirm_or_exit "Import SQL to ${COLOR_QUESTION_H}${database}${COLOR_QUESTION} database at ${COLOR_QUESTION_H}${docker_container_name}${COLOR_QUESTION} docker container from ${COLOR_QUESTION_H}${export_file_name}${COLOR_QUESTION} export file and ${COLOR_QUESTION_H}${trigger_file_name}${COLOR_QUESTION} trigger file?"

printf "${COLOR_INFO_B}Import ${COLOR_INFO_H}${export_file_name}${COLOR_INFO_B} export file to ${COLOR_INFO_H}${database}${COLOR_INFO_B} database on ${COLOR_INFO_H}${docker_container_name}${COLOR_INFO_B} docker container ${COLOR_INFO} \n"
docker exec -i ${docker_container_name} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtual_data_dir_path}${export_file_name}
color_reset

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
	printf "${COLOR_INFO_B}Execute ${COLOR_INFO_H}${trigger_file_name}${COLOR_INFO_B} trigger file to ${COLOR_INFO_H}${database}${COLOR_INFO_B} database on ${COLOR_INFO_H}${docker_container_name}${COLOR_INFO_B} docker container ${COLOR_INFO} \n"
	docker exec -i ${docker_container_name} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtual_trigger_dir_path}${trigger_file_name}
	color_reset
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"

print_new_line
