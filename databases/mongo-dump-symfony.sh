#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_base.sh


## CONFIG
backup_dir_path=${HOME}/backup/


## WELCOME
program_title "Mongo dump on Symfony app"


## VARIABLES
_directory="master"
prompt_variable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 1 "$@"
symfony_config_file_path=${HOME}/${directory}/app/config/parameters.yml
mongo_host=$(sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$mongo_host" == "~" || "$mongo_host" == "" || "$mongo_host" == "null" ]]; then
	mongo_host='localhost'
fi
mongo_port=$(sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$mongo_port" == "~" || "$mongo_port" == "" || "$mongo_port" == "null" ]]; then
	mongo_port=27017
fi
mongo_user=$(sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$mongo_user" == "~" || "$mongo_user" == "" || "$mongo_user" == "null" ]]; then
	mongo_user='root'
fi
mongo_pass=$(sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$mongo_pass" == "~" || "$mongo_pass" == "" || "$mongo_pass" == "null" ]]; then
	mongo_pass=''
fi
mongo_base=$(sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" $symfony_config_file_path | xargs)
_export_dir_name="${mongo_base}-$(date "+%Y%m%d-%H%M%S")"
prompt_variable export_dir_name "Export dirname" "$_export_dir_name" 2 "$@"
_export_file_name="${mongo_base}-$(date "+%Y%m%d-%H%M%S").tar.gz"
prompt_variable export_file_name "Export filename" "$_export_file_name" 3 "$@"
_backup_time=0
prompt_variable backup_time "Backup time (days)" "$_backup_time" 4 "$@"


## PROGRAM
confirm_or_exit "Dump Mongo from ${COLOR_QUESTION_H}${mongo_user}@${mongo_host}/${mongo_base}${COLOR_QUESTION_B} base to ${COLOR_QUESTION_H}${export_file_name}${COLOR_QUESTION_B} file?"

printf "${COLOR_INFO_B}Dumping database ${COLOR_INFO} \n"
mkdir -p ${backup_dir_path}
mongodump --host ${mongo_host} --port ${mongo_port} --username ${mongo_user} --password ${mongo_pass} --db ${mongo_base} --out ${backup_dir_path} --gzip
(cd ${backup_dir_path} && mv ${mongo_base} ${export_dir_name})
(cd ${backup_dir_path} && tar -zcvf ${backup_dir_path}${export_file_name} ${export_dir_name} && rm -rf ${export_dir_name})

if [[ $backup_time > 0 ]]; then
	printf "${COLOR_NOTICE_B}Clean old backups ${COLOR_NOTICE} \n"
	find ${backup_dir_path} -mtime +${backup_time} -exec rm {} \;
fi

print_new_line
