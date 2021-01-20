###############################################################
### mySQL operations
###############################################################

function symfony_database_migrate() {
    local symfony_console=$1
    local interactive=${2:-"y"}
    local has_migrations=$(${symfony_console} doc:mig:sta --no-ansi | grep "New Migrations" | sed 's/[^0-9]//g')

    if [[ -n "$symfony_console" ]]; then
        if [[ "$has_migrations" != "0" ]]; then
            printf "${COLOR_NOTICE_B}Database has new structure${COLOR_OFF} \n"
            ${symfony_console} doctrine:schema:update --dump-sql
            printf "${COLOR_NOTICE_B}Database has new migrations${COLOR_OFF} \n"
            ${symfony_console} doc:mig:sta --show-versions | grep "not migrated"
            printf "${COLOR_CONSOLE}${symfony_console} doctrine:migrations:migrate${COLOR_OFF}\n\n"
            if [[ "$interactive" == "n" ]]; then
                ${symfony_console} doctrine:migrations:migrate --no-interaction
            else
                ${symfony_console} doctrine:migrations:migrate
            fi
        else
            printf "${COLOR_INFO_B}Database is in sync with the current entity metadata${COLOR_INFO} \n"
        fi
    else
        printf "${COLOR_ERROR_B}ERROR: Database migrate via Symfony: console command not defined!${COLOR_ERROR} \n"
    fi
}

function mysql_remote_truncate_via_symfony() {
    local host_name=$1
    local symfony_console=$2

    if [[ -n "$host_name" ]]; then
        if [[ -n "$symfony_console" ]]; then
            printf "${COLOR_INFO_B}Truncate database at ${COLOR_INFO_H}${host_name}${COLOR_INFO_B} host with ${COLOR_INFO_H}${symfony_console}${COLOR_INFO_B}${COLOR_INFO}\n"
            ssh ${host_name} ''${symfony_console}' doctrine:database:drop --force && '${symfony_console}' doctrine:database:create'
        else
            printf "${COLOR_ERROR_B}ERROR: Database truncate via Symfony: console command not defined!${COLOR_ERROR} \n"
        fi
    else
        printf "${COLOR_ERROR_B}ERROR: Database truncate via Symfony: host name not defined!${COLOR_ERROR} \n"
    fi
}

function mysql_remote_check_via_symfony() {
    local host_name=$1
    local symfony_root_dir=$2
    local sql_status=$(ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysql -f --skip-column-names --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base -e "SELECT \"OK\" AS \"status\"" || { printf "No config file"; exit 1; }' 2>&1 | sed ':a;N;$!ba;s/\n//g' | sed 's/mysql\: \[Warning\] Using a password on the command line interface can be insecure.//g')
    printf "${COLOR_INFO_B}%16s ${COLOR_INFO_H}%60s${COLOR_INFO_B}\t" "MYSQL" "${host_name}/${symfony_root_dir}"
    if [[ "$sql_status" == "OK" ]]; then
        printf "${COLOR_SUCCESS_H}"
    else
        if [[ "$sql_status" == "No config file" ]]; then
            printf "${COLOR_LOG_H}"
        else
            printf "${COLOR_ERROR_H}"
        fi
    fi
    printf "%s\n${COLOR_LOG}" "$sql_status"
}

function mysql_remote_query_via_symfony() {
    local host_name=$1
    local symfony_root_dir=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${COLOR_INFO_B}Run query at ${COLOR_INFO_H}${host_name}${COLOR_INFO_B} in ${COLOR_INFO_H}${symfony_root_dir}${COLOR_INFO_B} directory${COLOR_INFO}\n"
    ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && printf "'$sql_query'" | mysql --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base'
}

function mysql_remote_export_via_symfony() {
    local host_name=$1
    local symfony_root_dir=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${COLOR_INFO_B}Backup MySQL database at ${COLOR_INFO_H}${host_name}${COLOR_INFO_B} host in ${COLOR_INFO_H}${symfony_root_dir}${COLOR_INFO_B} director (via Symfony config)${COLOR_INFO}\n"
    ssh ${host_name} 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysqldump --routines --events --triggers --single-transaction --host=$sql_host --port=$sql_port --user=$sql_user --password=$sql_pass $sql_base > ${HOME}/'${file_name}''
}

function mysql_remote_import_via_symfony() {
    local host_name=$1
    local symfony_root_dir=$2
    local file_name=$3
    file_name_check "$file_name"

    printf "${COLOR_INFO_B}Import MySQL database at ${COLOR_INFO_H}${host_name}${COLOR_INFO_B} host in ${COLOR_INFO_H}${symfony_root_dir}${COLOR_INFO_B} directory (via Symfony config)${COLOR_INFO}\n"
    ssh $host_name 'symfony_config_file_path='${symfony_root_dir}'app/config/parameters.yml && sql_host=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_host" == "~" || "$sql_host" == "" || "$sql_host" == "null" ]]; then sql_host="localhost"; fi && sql_port=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_port" == "~" || "$sql_port" == "" || "$sql_port" == "null" ]]; then sql_port="3306"; fi && sql_user=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfony_config_file_path | xargs`; if [[ "$sql_user" == "~" || "$sql_user" == "" || "$sql_user" == "null" ]]; then sql_user="root"; fi && sql_pass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfony_config_file_path | xargs` && sql_base=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfony_config_file_path | xargs` && mysql --host=$sql_host --user=$sql_user --port=$sql_port --password=$sql_pass $sql_base < ${HOME}/'${file_name}''
}

function mysql_backup_via_symfony() {
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

    printf "${COLOR_INFO_B}Backup ${COLOR_INFO_H}%s${COLOR_INFO_B} MySQL database to ${COLOR_INFO_H}%s${COLOR_INFO_B} file (via Symfony config)${COLOR_INFO} \n" "$sql_host:$sql_port/$sql_base" "$backup_dir_path$backup_file_name"
    mkdir -p ${backup_dir_path}
    mysqldump --host="$sql_host" --port="$sql_port" --user="$sql_user" --password="$sql_pass" "$sql_base" >${backup_dir_path}${backup_file_name}
}

function mongo_backup_via_symfony() {
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

    printf "${COLOR_INFO_B}Backup ${COLOR_INFO_H}%s${COLOR_INFO_B} Mongo database to ${COLOR_INFO_H}%s${COLOR_INFO_B} directory (via Symfony config)${COLOR_INFO}\n" "$mongo_host/$mongo_base" "$backup_dir_path"
    mkdir -p ${backup_dir_path}
    mongodump --host "$mongo_host" --port "$mongo_port" --username "$mongo_user" --password "$mongo_pass" --db "$mongo_base"
}

function mongo_restore_via_symfony() {
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
        printf "${COLOR_INFO_B}Restore from ${COLOR_INFO_H}%s${COLOR_INFO_B} path to ${COLOR_INFO_H}%s${COLOR_INFO_B} mongo database (via Symfony config)${COLOR_INFO}\n" "$backup_dir_path" "$mongo_host/$mongo_base"
        mongorestore --host "$mongo_host" --port "$mongo_port" --username "$mongo_user" --password "$mongo_pass" --db ${mongo_base} --drop ${backup_dir_path}
    else
        printf "${COLOR_ERROR_B}Source ${COLOR_ERROR_H}%s${COLOR_ERROR_B} path can not be restored to ${COLOR_ERROR_H}%s${COLOR_ERROR_B} mongo database (via Symfony config)${COLOR_ERROR}\n" "$backup_dir_path" "$mongo_host/$mongo_base"
    fi
}
