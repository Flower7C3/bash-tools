###############################################################
### mySQL operations
###############################################################

function symfony_database_migrate {
	local symfony_console=$1
	local interactive=${2:-"y"}
    local has_migrations=$(${symfony_console} doc:mig:sta --no-ansi | grep "New Migrations" | sed 's/[^0-9]//g')

    if [[ -n "$symfony_console" ]]; then
        if [[ "$has_migrations" != "0" ]]; then
            printf "${color_notice_b}Database has new structure${color_off} \n"
            ${symfony_console} doctrine:schema:update --dump-sql
            printf "${color_notice_b}Database has new migrations${color_off} \n"
            ${symfony_console} doc:mig:sta --show-versions | grep "not migrated"
            printf "${color_console}${symfony_console} doctrine:migrations:migrate${color_off}\n\n"
            if [[ "$interactive" == "n" ]]; then
                ${symfony_console} doctrine:migrations:migrate --no-interaction
            else
                ${symfony_console} doctrine:migrations:migrate
            fi
        else
            printf "${color_info_b}Database is in sync with the current entity metadata${color_info} \n"
        fi
    else
        printf "${color_error_b}ERROR: Database migrate via Symfony: console command not defined!${color_error} \n"
    fi
}

function mysql_remote_truncate_via_symfony {
	local host_name=$1
	local symfony_console=$2

    if [[ -n "$host_name" ]]; then
        if [[ -n "$symfony_console" ]]; then
            printf "${color_info_b}Truncate database at ${color_info_h}${host_name}${color_info_b} host with ${color_info_h}${symfony_console}${color_info_b}${color_info}\n"
            ssh ${host_name} ''${symfony_console}' doctrine:database:drop --force && '${symfony_console}' doctrine:database:create'
        else
            printf "${color_error_b}ERROR: Database truncate via Symfony: console command not defined!${color_error} \n"
        fi
    else
        printf "${color_error_b}ERROR: Database truncate via Symfony: host name not defined!${color_error} \n"
    fi
}

function mysql_remote_check_via_symfony {
   	local host_name=$1
	local symfony_root_dir=$2
    local sql_status=$(ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysql -f --skip-column-names --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base -e "SELECT \"OK\" AS \"status\"" || { printf "No config file"; exit 1; }' 2>&1 | sed ':a;N;$!ba;s/\n//g' | sed 's/mysql\: \[Warning\] Using a password on the command line interface can be insecure.//g')
    printf "${color_info_b}%16s ${color_info_h}%60s${color_info_b}\t" "MYSQL" "${host_name}/${symfony_root_dir}"
    if [[ "$sql_status" == "OK" ]]; then
        printf "${color_success_h}"
    else
        if [[ "$sql_status" == "No config file" ]]; then
            printf "${color_log_h}"
        else
            printf "${color_error_h}"
        fi
    fi
    printf "%s\n${color_log}" "$sql_status"
}

function mysql_remote_query_via_symfony {
	local host_name=$1
	local symfony_root_dir=$2
	local file_name=$3
	file_name_check "$file_name"

	printf "${color_info_b}Run query at ${color_info_h}${host_name}${color_info_b} in ${color_info_h}${symfony_root_dir}${color_info_b} directory${color_info}\n"
	ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && printf "'$sql_query'" | mysql --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base'
}

function mysql_remote_export_via_symfony {
	local host_name=$1
	local symfony_root_dir=$2
	local file_name=$3
	file_name_check "$file_name"

	printf "${color_info_b}Backup MySQL database at ${color_info_h}${host_name}${color_info_b} host in ${color_info_h}${symfony_root_dir}${color_info_b} director (via Symfony config)${color_info}\n"
	ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysqldump --routines --events --triggers --single-transaction --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base > ${HOME}/'${file_name}''
}

function mysql_remote_import_via_symfony {
	local host_name=$1
	local symfony_root_dir=$2
	local file_name=$3
	file_name_check "$file_name"

	printf "${color_info_b}Import MySQL database at ${color_info_h}${host_name}${color_info_b} host in ${color_info_h}${symfony_root_dir}${color_info_b} directory (via Symfony config)${color_info}\n"
	ssh $host_name 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysql --host=$sql_host --user=$sql_user --port=$sql_port --password=$sql_pass $sql_base < ${HOME}/'${file_name}''
}

function mysql_backup_via_symfony {
    local symfony_root_dir=$1
    local symfony_config_file_path="${symfony_root_dir}app/config/parameters.yml"

    local sql_host=$(sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then
	    sql_host='localhost'
    fi
    local sql_port=$(sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then
	    sql_port='3306'
    fi
    local sql_user=$(sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then
	    sql_user='root'
    fi
    local sql_pass=$(sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    local sql_base=$(sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)

    local backup_dir_path=${2:-'dump/'}
    local backup_file_name="${sql_host}.${sql_base}.$(date "+%Y%m%d.%H%M%S").sql"

    printf "${color_info_b}Backup ${color_info_h}%s${color_info_b} MySQL database to ${color_info_h}%s${color_info_b} file (via Symfony config)${color_info} \n" "$sql_host:$sql_port/$sql_base" "$backup_dir_path$backup_file_name"
    mkdir -p ${backup_dir_path}
    mysqldump --host="$sql_host" --port="$sql_port" --user="$sql_user" --password="$sql_pass" "$sql_base" > ${backup_dir_path}${backup_file_name}
}

function mongo_backup_via_symfony {
    local symfony_root_dir=$1
    local symfony_config_file_path="${symfony_root_dir}app/config/parameters.yml"

    local mongo_host=$(sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_host" == "~" || "$mongo_host" == "" || "$mongo_host" == "null" ]]; then
        mongo_host='localhost'
    fi
    local mongo_port=$(sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_port" == "~" || "$mongo_port" == "" || "$mongo_port" == "null" ]]; then
        mongo_port=27017
    fi
    local mongo_user=$(sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_user" == "~" || "$mongo_user" == "" || "$mongo_user" == "null" ]]; then
        mongo_user='root'
    fi
    local mongo_pass=$(sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_pass" == "~" || "$mongo_pass" == "" || "$mongo_pass" == "null" ]]; then
        mongo_pass=''
    fi
    local mongo_base=$(sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    local backup_dir_name=${2:-'dump/'}
    local backup_dir_path="${backup_dir_name}${mongo_base}/"

    printf "${color_info_b}Backup ${color_info_h}%s${color_info_b} Mongo database to ${color_info_h}%s${color_info_b} directory (via Symfony config)${color_info}\n" "$mongo_host/$mongo_base" "$backup_dir_path"
    mkdir -p ${backup_dir_path}
    mongodump --host "$mongo_host" --port "$mongo_port" --username "$mongo_user" --password "$mongo_pass" --db "$mongo_base"
}

function mongo_restore_via_symfony {
    local symfony_root_dir=$1
    local symfony_config_file_path="${symfony_root_dir}app/config/parameters.yml"

    local mongo_host=$(sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_host" == "~" || "$mongo_host" == "" || "$mongo_host" == "null" ]]; then
        mongo_host='localhost'
    fi
    local mongo_port=$(sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_port" == "~" || "$mongo_port" == "" || "$mongo_port" == "null" ]]; then
        mongo_port=27017
    fi
    local mongo_user=$(sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_user" == "~" || "$mongo_user" == "" || "$mongo_user" == "null" ]]; then
        mongo_user='root'
    fi
    local mongo_pass=$(sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    if [[ "$mongo_pass" == "~" || "$mongo_pass" == "" || "$mongo_pass" == "null" ]]; then
        mongo_pass=''
    fi
    local mongo_base=$(sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" ${symfony_config_file_path} | xargs)
    local source_base=$2
    local backup_dir_name=${3:-'dump/'}
    local backup_dir_path="${backup_dir_name}${source_base}/"

    if [ -d "$backup_dir_path" ]; then
        printf "${color_info_b}Restore from ${color_info_h}%s${color_info_b} path to ${color_info_h}%s${color_info_b} mongo database (via Symfony config)${color_info}\n" "$backup_dir_path" "$mongo_host/$mongo_base"
        mongorestore --host "$mongo_host" --port "$mongo_port" --username "$mongo_user" --password "$mongo_pass" --db ${mongo_base} --drop ${backup_dir_path}
    else
        printf "${color_error_b}Source ${color_error_h}%s${color_error_b} path can not be restored to ${color_error_h}%s${color_error_b} mongo database (via Symfony config)${color_error}\n" "$backup_dir_path" "$mongo_host/$mongo_base"
    fi
}
