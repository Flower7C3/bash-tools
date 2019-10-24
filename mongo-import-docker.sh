#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_docker_container_name="mongo3"
_mongo_base="example"
_export_dir_name="backup_$(date "+%Y%m%d-%H%M%S")"
_export_file_name="backup_$(date "+%Y%m%d-%H%M%S").tar.gz"


## WELCOME
program_title "Mongo import to docker"


## VARIABLES
prompt_variable docker_container_name "Docker container name" "$_docker_container_name" 1 "$@"
prompt_variable mongo_base "Docker Mongo database name" "$_mongo_base" 2 "$@"

local_data_dir_path="${HOME}/www/database/mongo/${docker_container_name}/data/"
local_trigger_dir_path="${HOME}/www/database/mongo/${docker_container_name}/data/"
virtual_data_dir_path="/data/db/"
virtual_trigger_dir_path="/data/db/"
trigger_file_name=${mongo_base}".json"

prompt_variable export_dir_name "Export dir name (from ${COLOR_QUESTION_H}${local_data_dir_path}${COLOR_QUESTION_B} path)" "$_export_dir_name" 3 "$@"
prompt_variable export_file_name "Export file name (from ${COLOR_QUESTION_H}${local_data_dir_path}${COLOR_QUESTION_B} path)" "$_export_file_name" 4 "$@"


## PROGRAM
confirm_or_exit "Import Mongo to ${COLOR_QUESTION_H}${mongo_base}${COLOR_QUESTION} database at ${COLOR_QUESTION_H}${docker_container_name}${COLOR_QUESTION} docker container from ${COLOR_QUESTION_H}${export_file_name}${COLOR_QUESTION} export file and ${COLOR_QUESTION_H}${trigger_file_name}${COLOR_QUESTION} trigger file?"

printf "${COLOR_INFO_B}Import ${COLOR_INFO_H}${export_file_name}${COLOR_INFO_B} export file to ${COLOR_INFO_H}${mongo_base}${COLOR_INFO_B} database on ${COLOR_INFO_H}${docker_container_name}${COLOR_INFO_B} docker container ${COLOR_INFO} \n"
$(cd ${local_data_dir_path} && tar xzf ${export_file_name})
docker exec -i ${docker_container_name} sh -c 'exec mongorestore --drop --db '${mongo_base}' --gzip --dir '${virtual_data_dir_path}${export_dir_name}''
color_reset

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
	printf "${COLOR_INFO_B}Execute ${COLOR_INFO_H}${trigger_file_name}${COLOR_INFO_B} trigger file to ${COLOR_INFO_H}${mongo_base}${COLOR_INFO_B} database on ${COLOR_INFO_H}${docker_container_name}${COLOR_INFO_B} docker container ${COLOR_INFO} \n"
	docker exec -t ${docker_container_name} sh -c 'exec mongo < '${virtual_trigger_dir_path}${trigger_file_name}
	color_reset
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"
remove_dir_from_local "${local_data_dir_path}" "${export_dir_name}"

print_new_line
