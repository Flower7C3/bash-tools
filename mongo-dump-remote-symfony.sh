#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_remote_host="example-server-dev"
_directory="dev"
remote_data_dir_path='${HOME}/backup/'
local_data_dir_path="${HOME}/backup/"


## WELCOME
program_title "Mongo dump on remote Symfony app"


## VARIABLES
prompt_variable remote_host "Remote host name (from SSH config file)"  "$_remote_host" 1 "$@"
_export_dir_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S")"
_export_file_name="backup_${remote_host}_$(date "+%Y%m%d-%H%M%S").tar.gz"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 2 "$@"
prompt_variable export_dir_name "Export dirname" "$_export_dir_name" 3 "$@"
prompt_variable export_file_name "Export filename" "$_export_file_name" 4 "$@"


## PROGRAM
confirm_or_exit "Dump Mongo on ${color_question_h}${remote_host}${color_question} host from ${color_question_h}${directory}${color_question} directory?"

sourced_scripts_list+=('mongo-dump-symfony.sh mongo-dump-symfony.sh')
copy_scripts_to_host "$remote_host"

ssh ${remote_host} 'yes | bash ${HOME}/mongo-dump-symfony.sh '${directory}' '${export_dir_name}' '${export_file_name} 0

move_file_from_host_to_local "${remote_host}" "${remote_data_dir_path}" "${local_data_dir_path}" "${export_file_name}"

remove_scripts_from_host "$remote_host"

program_end
