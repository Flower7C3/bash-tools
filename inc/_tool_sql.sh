###############################################################
### mySQL operations
###############################################################

function symfony_database_migrate {
	local symfonyConsole=$1
    local hasMigrations=$(${symfonyConsole} doc:mig:sta | grep "New Migrations" | sed 's/[^0-9]//g')

    if [[ "$hasMigrations" != "0" ]]; then
        printf "${NoticeB}Database has new structure${Color_Off} \n"
        ${symfonyConsole} doctrine:schema:update --dump-sql
        ${symfonyConsole} doc:mig:sta --show-versions | grep "not migrated"
        printf "${Black}${On_Cyan}${symfonyConsole} doctrine:migrations:migrate${Color_Off}\n\n"
        ${symfonyConsole} doctrine:migrations:migrate
    else
        printf "${InfoB}Database is in sync with the current entity metadata${Info} \n"
    fi
}

function mysql_remote_truncate_via_symfony {
	local hostName=$1
	local symfonyRootDir=$2

	printf "${InfoB}Truncate database at ${InfoBI}${hostName}${InfoB} host in ${InfoBI}${symfonyRootDir}${InfoB} directory${Info}\n"
	ssh ${hostName} 'php '${symfonyRootDir}'app/console doctrine:database:drop --force && php '${symfonyRootDir}'app/console doctrine:database:create'
}

function mysql_remote_check_via_symfony {
   	local hostName=$1
	local symfonyRootDir=$2
    local sqlStatus=$(ssh ${hostName} 'symfonyConfigFilePath='${symfonyRootDir}'app/config/parameters.yml && sqlHost=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then sqlHost="localhost"; fi && sqlPort=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then sqlPort="3306"; fi && sqlUser=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then sqlUser="root"; fi && sqlPass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfonyConfigFilePath | xargs` && sqlBase=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfonyConfigFilePath | xargs` && mysql -f --skip-column-names --host=$sqlHost --port=sqlPort --user=$sqlUser --password=$sqlPass $sqlBase -e "SELECT \"OK\" AS \"status\"" || { printf "No config file"; exit 1; }' 2>&1 | sed ':a;N;$!ba;s/\n//g' | sed 's/mysql\: \[Warning\] Using a password on the command line interface can be insecure.//g')
    printf "${InfoB}%16s ${InfoBI}%60s${InfoB}\t" "MYSQL" "${hostName}/${symfonyRootDir}"
    if [[ "$sqlStatus" == "OK" ]]; then
        printf "${SuccessBI}"
    else
        if [[ "$sqlStatus" == "No config file" ]]; then
            printf "${LogBI}"
        else
            printf "${ErrorBI}"
        fi
    fi
    printf "%s\n${Log}" "$sqlStatus"
}

function mysql_remote_query_via_symfony {
	local hostName=$1
	local symfonyRootDir=$2
	local fileName=$3
	file_name_check "$fileName"

	printf "${InfoB}Run query at ${InfoBI}${hostName}${InfoB} in ${InfoBI}${symfonyRootDir}${InfoB} directory${Info}\n"
	ssh ${hostName} 'symfonyConfigFilePath='${symfonyRootDir}'app/config/parameters.yml && sqlHost=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then sqlHost="localhost"; fi && sqlPort=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then sqlPort="3306"; fi && sqlUser=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then sqlUser="root"; fi && sqlPass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfonyConfigFilePath | xargs` && sqlBase=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`
     && printf "'$sqlQuery'" | mysql --host=$sqlHost --port=sqlPort --user=$sqlUser --password=$sqlPass $sqlBase'
}

function mysql_remote_export_via_symfony {
	local hostName=$1
	local symfonyRootDir=$2
	local fileName=$3
	file_name_check "$fileName"

	printf "${InfoB}Backup MySQL database at ${InfoBI}${hostMaster}${InfoB} host in ${InfoBI}${symfonyRootDir}${InfoB} director (via Symfony config)y${Info}\n"
	ssh ${hostName} 'symfonyConfigFilePath='${symfonyRootDir}'app/config/parameters.yml && sqlHost=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then sqlHost="localhost"; fi && sqlPort=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then sqlPort="3306"; fi && sqlUser=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then sqlUser="root"; fi && sqlPass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfonyConfigFilePath | xargs` && sqlBase=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`
	    && mysqldump --routines --events --triggers --single-transaction --host=$sqlHost --port=sqlPort --user=$sqlUser --password=$sqlPass $sqlBase > ${HOME}/'${fileName}''
}

function mysql_remote_import_via_symfony {
	local hostName=$1
	local symfonyRootDir=$2
	local fileName=$3
	file_name_check "$fileName"

	printf "${InfoB}Import MySQL database at ${InfoBI}${hostName}${InfoB} host in ${InfoBI}${symfonyRootDir}${InfoB} directory (via Symfony config)${Info}\n"
	ssh $hostName 'symfonyConfigFilePath='${symfonyRootDir}'app/config/parameters.yml && sqlHost=`sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then sqlHost="localhost"; fi && sqlPort=`sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then sqlPort="3306"; fi && sqlUser=`sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`; if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then sqlUser="root"; fi && sqlPass=`sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $symfonyConfigFilePath | xargs` && sqlBase=`sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $symfonyConfigFilePath | xargs`
	     && mysql --host=$sqlHost --user=$sqlUser --port=sqlPort --password=$sqlPass $sqlBase < ${HOME}/'${fileName}''
}

function mysql_backup_via_symfony {
    local symfonyRootDir=$1
    local symfonyConfigFilePath="${symfonyRootDir}app/config/parameters.yml"

    local sqlHost=$(sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then
	    sqlHost='localhost'
    fi
    local sqlPort=$(sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then
	    sqlPort='3306'
    fi
    local sqlUser=$(sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then
	    sqlUser='root'
    fi
    local sqlPass=$(sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    local sqlBase=$(sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)

    local backupDir="dump/"
    local backupFileName=${1:-${sqlHost}.${sqlBase}.$(date "+%Y%m%d.%H%M%S").sql}

    printf "${InfoB}Backup ${InfoBI}%s${InfoB} MySQL database to ${InfoBI}%s${InfoB} file (via Symfony config)${Info} \n" "$sqlHost:$sqlPort/$sqlBase" "$backupDir$backupFileName"
    mkdir -p ${backupDir}
    mysqldump --host="$sqlHost" --port="$sqlPort" --user="$sqlUser" --password="$sqlPass" "$sqlBase" > ${backupDir}${backupFileName}
}

function mongo_backup_via_symfony {
    local symfonyRootDir=$1
    local symfonyConfigFilePath="${symfonyRootDir}app/config/parameters.yml"

    local mongoHost=$(sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoHost" == "~" || "$mongoHost" == "" || "$mongoHost" == "null" ]]; then
        mongoHost='localhost'
    fi
    local mongoPort=$(sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoPort" == "~" || "$mongoPort" == "" || "$mongoPort" == "null" ]]; then
        mongoPort=27017
    fi
    local mongoUser=$(sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoUser" == "~" || "$mongoUser" == "" || "$mongoUser" == "null" ]]; then
        mongoUser='root'
    fi
    local mongoPass=$(sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoPass" == "~" || "$mongoPass" == "" || "$mongoPass" == "null" ]]; then
        mongoPass=''
    fi
    local mongoBase=$(sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    local backupDir="dump/${mongoBase}/"

    printf "${InfoB}Backup ${InfoBI}%s${InfoB} Mongo database to ${InfoBI}%s${InfoB} directory (via Symfony config)${Info}\n" "$mongoHost/$mongoBase" "$backupDir"
    mkdir -p ${backupDir}
    mongodump --host "$mongoHost" --port "$mongoPort" --username "$mongoUser" --password "$mongoPass" --db "$mongoBase"
}

function mongo_restore_via_symfony {
    local symfonyRootDir=$1
    local symfonyConfigFilePath="${symfonyRootDir}app/config/parameters.yml"

    local mongoHost=$(sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoHost" == "~" || "$mongoHost" == "" || "$mongoHost" == "null" ]]; then
        mongoHost='localhost'
    fi
    local mongoPort=$(sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoPort" == "~" || "$mongoPort" == "" || "$mongoPort" == "null" ]]; then
        mongoPort=27017
    fi
    local mongoUser=$(sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoUser" == "~" || "$mongoUser" == "" || "$mongoUser" == "null" ]]; then
        mongoUser='root'
    fi
    local mongoPass=$(sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    if [[ "$mongoPass" == "~" || "$mongoPass" == "" || "$mongoPass" == "null" ]]; then
        mongoPass=''
    fi
    local mongoBase=$(sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" ${symfonyConfigFilePath} | xargs)
    sourceBase=$1
    local backupDir="dump/${sourceBase}/"

    if [ -d "$backupDir" ]; then
        printf "${InfoB}Restore from ${InfoBI}%s${InfoB} path to ${InfoBI}%s${InfoB} mongo database (via Symfony config)${Info}\n" "$backupDir" "$mongoHost/$mongoBase"
        mongorestore --host "$mongoHost" --port "$mongoPort" --username "$mongoUser" --password "$mongoPass" --db ${mongoBase} --drop ${backupDir}
    else
        printf "${ErrorB}Source ${ErrorBI}%s${ErrorB} path can not be restored to ${ErrorBI}%s${ErrorB} mongo database (via Symfony config)${Error}\n" "$backupDir" "$mongoHost/$mongoBase"
    fi
}
