#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_sql_host="mysql55"
_database="example"
datetime=$(date "+%Y%m%d-%H%M%S")
_export_file_name="backup_${datetime}.sql"


## WELCOME
program_title "SQL import to local"


## VARIABLES
prompt_variable export_file_name "Export file name" "$_export_file_name" 1 "$@"
prompt_variable sql_host "Local MySQL machine name" "$_sql_host" 2 "$@"
prompt_variable database "Local MySQL database name" "$_database" 3 "$@"

local_data_dir_path="${HOME}/backup/"
local_trigger_dir_path="${HOME}/www/database/"
trigger_file_name=${database}".sql"



## PROGRAM
confirm_or_exit "Import SQL to ${color_question_h}${database}${color_question} database at ${color_question_h}${sql_host}${color_question} mysql host from ${color_question_h}${export_file_name}${color_question} export file and ${color_question_h}${trigger_file_name}${color_question} trigger file?"

printf "${color_info_b}Import ${color_info_h}${export_file_name}${color_info_b} export file to ${color_info_h}${database}${color_info_b} database on local ${color_info} \n"
mysql ${database} < ${local_data_dir_path}${export_file_name}
printf "${color_off}"

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
  printf "${color_info_b}Execute ${color_info_h}${trigger_file_name}${color_info_b} trigger file  to ${color_info_h}${database}${color_info_b} database on local ${color_info} \n"
  mysql ${database} < ${local_trigger_dir_path}${trigger_file_name}
  printf "${color_off}"
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"

print_new_line
