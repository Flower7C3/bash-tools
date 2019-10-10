#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


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

prompt_variable export_dir_name "Export dir name (from ${color_question_h}${local_data_dir_path}${color_question_b} path)" "$_export_dir_name" 3 "$@"
prompt_variable export_file_name "Export file name (from ${color_question_h}${local_data_dir_path}${color_question_b} path)" "$_export_file_name" 4 "$@"



## PROGRAM
confirm_or_exit "Import SQL to ${color_question_h}${mongo_base}${color_question} database at ${color_question_h}${sql_host}${color_question} mysql host from ${color_question_h}${export_file_name}${color_question} export file and ${color_question_h}${trigger_file_name}${color_question} trigger file?"

printf "${color_info_b}Import ${color_info_h}${export_file_name}${color_info_b} export file to ${color_info_h}${mongo_base}${color_info_b} database on local ${color_info} \n"
$(cd ${local_data_dir_path} && tar xzf ${export_file_name})
mongorestore --host ${mongo_host} --drop --db ${mongo_base} --gzip --dir ${local_data_dir_path}${export_dir_name}
printf "${color_off}"

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
  printf "${color_info_b}Execute ${color_info_h}${trigger_file_name}${color_info_b} trigger file to ${color_info_h}${mongo_base}${color_info_b} database on local ${color_info} \n"
  mongo --host ${mongo_host} < ${local_trigger_dir_path}${trigger_file_name}
  printf "${color_off}"
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"
remove_dir_from_local "${local_data_dir_path}" "${export_dir_name}"

display_new_line
