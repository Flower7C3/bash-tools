#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh


## CONFIG
_mongo_host="localhost"
_mongo_base="example"
_export_dir_name="backup_$(date "+%Y%m%d-%H%M%S")"
_export_file_name="backup_$(date "+%Y%m%d-%H%M%S").tar.gz"


## WELCOME
program_title "SQL import to local"


## VARIABLES
prompt_variable mongo_host "Mongo host" "$_mongo_host" 1 "$@"
prompt_variable mongo_base "Mongo database name" "$_mongo_base" 2 "$@"

local_data_dir_path="${HOME}/backup/"
local_trigger_dir_path="${HOME}/www/database/"
trigger_file_name=${mongo_base}".json"

prompt_variable export_dir_name "Export dir name (from ${COLOR_QUESTION_H}${local_data_dir_path}${COLOR_QUESTION_B} path)" "$_export_dir_name" 3 "$@"
prompt_variable export_file_name "Export file name (from ${COLOR_QUESTION_H}${local_data_dir_path}${COLOR_QUESTION_B} path)" "$_export_file_name" 4 "$@"



## PROGRAM
confirm_or_exit "Import SQL to ${COLOR_QUESTION_H}${mongo_base}${COLOR_QUESTION} database at ${COLOR_QUESTION_H}${sql_host}${COLOR_QUESTION} mysql host from ${COLOR_QUESTION_H}${export_file_name}${COLOR_QUESTION} export file and ${COLOR_QUESTION_H}${trigger_file_name}${COLOR_QUESTION} trigger file?"

printf "${COLOR_INFO_B}Import ${COLOR_INFO_H}${export_file_name}${COLOR_INFO_B} export file to ${COLOR_INFO_H}${mongo_base}${COLOR_INFO_B} database on local ${COLOR_INFO} \n"
$(cd ${local_data_dir_path} && tar xzf ${export_file_name})
mongorestore --host ${mongo_host} --drop --db ${mongo_base} --gzip --dir ${local_data_dir_path}${export_dir_name}
color_reset

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
  printf "${COLOR_INFO_B}Execute ${COLOR_INFO_H}${trigger_file_name}${COLOR_INFO_B} trigger file to ${COLOR_INFO_H}${mongo_base}${COLOR_INFO_B} database on local ${COLOR_INFO} \n"
  mongo --host ${mongo_host} < ${local_trigger_dir_path}${trigger_file_name}
  color_reset
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"
remove_dir_from_local "${local_data_dir_path}" "${export_dir_name}"

print_new_line
