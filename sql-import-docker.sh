#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


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

prompt_variable export_file_name "Export file name (from ${color_question_h}${local_data_dir_path}${color_question_b} directory)" "$_export_file_name" 3 "$@"


## PROGRAM
confirm_or_exit "Import SQL to ${color_question_h}${database}${color_question} database at ${color_question_h}${docker_container_name}${color_question} docker container from ${color_question_h}${export_file_name}${color_question} export file and ${color_question_h}${trigger_file_name}${color_question} trigger file?"

printf "${color_info_b}Import ${color_info_h}${export_file_name}${color_info_b} export file to ${color_info_h}${database}${color_info_b} database on docker ${color_info} \n"
docker exec -i ${docker_container_name} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtual_data_dir_path}${export_file_name}
printf "${color_off}"

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
	printf "${color_info_b}Execute ${color_info_h}${trigger_file_name}${color_info_b} trigger file to ${color_info_h}${database}${color_info_b} database on docker ${color_info} \n"
	docker exec -i ${docker_container_name} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtual_trigger_dir_path}${trigger_file_name}
	printf "${color_off}"
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"

program_end
