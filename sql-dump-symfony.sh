#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
backup_dir_path=${HOME}/backup/


## WELCOME
program_title "SQL dump on Symfony app"


## VARIABLES
_directory="master"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 1 "$@"
config_file_path=${HOME}/${directory}/app/config/parameters.yml
sql_host=$(sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $config_file_path | xargs)
if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then
	sql_host='localhost'
fi
sql_port=$(sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $config_file_path | xargs)
if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then
	sql_port=3306
fi
sql_user=$(sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $config_file_path | xargs)
if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then
	sql_user='root'
fi
sql_pass=$(sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $config_file_path | xargs)
if [[ "$sql_pass" == "~" || "$sql_pass" == "" || "$sql_pass" == "null" ]]; then
	sql_pass=''
fi
sql_base=$(sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $config_file_path | xargs)
_export_file_name=${sql_base}-$(date "+%Y%m%d-%H%M%S").sql
prompt_variable export_file_name "Export filename" "$_export_file_name" 2 "$@"
_backup_time=0
prompt_variable backup_time "Backup time (days)" "$_backup_time" 3 "$@"


## PROGRAM
confirm_or_exit "Dump SQL from ${color_question_h}${sql_user}@${sql_host}/${sql_base}${color_question_b} base to ${color_question_h}${export_file_name}${color_question_b} file?"

printf "${color_info_b}Dumping database ${color_info} \n"
mkdir -p ${backup_dir_path}
mysqldump --host=${sql_host} --port=${sql_port} --user=${sql_user} --password=${sql_pass} --skip-lock-tables ${sql_base} > ${backup_dir_path}${export_file_name}

if [[ $backup_time > 0 ]]; then
	printf "${color_notice_b}Clean old backups ${color_notice} \n"
	find ${backup_dir_path} -mtime +${backup_time} -exec rm {} \;
fi

print_new_line
