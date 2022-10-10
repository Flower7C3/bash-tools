#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../vendor/Flower7C3/bash-helpers/_base.sh


## CONFIG
_remote_host="example-server-dev"
_directory="dev"
remote_data_dir_path='${HOME}/backup/'
local_data_dir_path="${HOME}/backup/"


## WELCOME
program_title "SQL dump on remote Symfony app"


## VARIABLES
prompt_variable remote_host "Remote host name (from SSH config file)"  "$_remote_host" 1 "$@"
_export_file_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S").sql"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 2 "$@"
prompt_variable export_file_name "Export filename" "${_export_file_name}" 3 "$@"


## PROGRAM
confirm_or_exit "Dump SQL on ${COLOR_QUESTION_H}${remote_host}${COLOR_QUESTION} host from ${COLOR_QUESTION_H}${directory}${COLOR_QUESTION} directory?"

sourced_scripts_list+=('sql-dump-symfony.sh sql-dump-symfony.sh')
copy_scripts_to_host "$remote_host"

ssh ${remote_host} 'yes | bash ${HOME}/sql-dump-symfony.sh '${directory}' '${export_file_name} 0

move_file_from_host_to_local "${remote_host}" "${remote_data_dir_path}" "${local_data_dir_path}" "${export_file_name}"

remove_scripts_from_host "$remote_host"

print_new_line
