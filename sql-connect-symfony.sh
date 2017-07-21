#!/usr/bin/env bash

symfony_config_file_path=${HOME}/${1:-master}/app/config/parameters.yml

sql_host=$(sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then
	sql_host='localhost'
fi
sql_port=$(sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then
	sql_port=3306
fi
sql_user=$(sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then
	sql_user='root'
fi
sql_pass=$(sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs)
if [[ "$sql_pass" == "~" || "$sql_pass" == "" || "$sql_pass" == "null" ]]; then
	sql_pass=''
fi
sql_base=$(sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs)

echo "mysql --host=${sql_host} --port=${sql_port} --user=${sql_user} --password=${sql_pass} ${sql_base}"
