#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh


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
confirm_or_exit "Import SQL to ${COLOR_QUESTION_H}${database}${COLOR_QUESTION} database at ${COLOR_QUESTION_H}${sql_host}${COLOR_QUESTION} mysql host from ${COLOR_QUESTION_H}${export_file_name}${COLOR_QUESTION} export file and ${COLOR_QUESTION_H}${trigger_file_name}${COLOR_QUESTION} trigger file?"

printf "${COLOR_INFO_B}Import ${COLOR_INFO_H}${export_file_name}${COLOR_INFO_B} export file to ${COLOR_INFO_H}${database}${COLOR_INFO_B} database on local ${COLOR_INFO} \n"
mysql ${database} < ${local_data_dir_path}${export_file_name}
color_reset

if [ -f "${local_trigger_dir_path}${trigger_file_name}" ]; then
  printf "${COLOR_INFO_B}Execute ${COLOR_INFO_H}${trigger_file_name}${COLOR_INFO_B} trigger file  to ${COLOR_INFO_H}${database}${COLOR_INFO_B} database on local ${COLOR_INFO} \n"
  mysql ${database} < ${local_trigger_dir_path}${trigger_file_name}
  color_reset
fi

remove_file_from_local "${local_data_dir_path}" "${export_file_name}"

print_new_line
