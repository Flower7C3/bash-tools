

###############################################################
### mySQL operations
###############################################################
function sqlTruncateSymfony {
	local hostName=$1
	local applicationDir=$2

	printf "${InfoB}Truncate database at ${InfoBI}${hostName}${InfoB} host in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostName 'php '${applicationDir}'app/console doctrine:database:drop --force && php '${applicationDir}'app/console doctrine:database:create'
}

function sqlCheckSymfony {
   	local hostName=$1
	local applicationDir=$2
    local sqlStatus=$(ssh ${hostName} 'sqlHost=`[[ -a '${applicationDir}'app/config/parameters.yml ]] && cat '${applicationDir}'app/config/parameters.yml | sed -n "s/database_host:\(.*\)/\1/p" | xargs` && sqlUser=`cat '${applicationDir}'app/config/parameters.yml | sed -n "s/database_user:\(.*\)/\1/p" | xargs` && sqlPass=`cat '${applicationDir}'app/config/parameters.yml | sed -n "s/database_password:\(.*\)/\1/p" | xargs` && sqlBase=`cat '${applicationDir}'app/config/parameters.yml | sed -n "s/database_name:\(.*\)/\1/p" | xargs` && mysql -f --skip-column-names --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase -e "SELECT \"OK\" AS \"status\"" || { printf "No config file"; exit 1; }' 2>&1 | sed ':a;N;$!ba;s/\n//g' | sed 's/mysql\: \[Warning\] Using a password on the command line interface can be insecure.//g')
    printf "${InfoB}%16s ${InfoBI}%60s${InfoB}\t" "MYSQL" "${hostName}/${applicationDir}"
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

function sqlQuerySymfony {
	local hostName=$1
	local applicationDir=$2
	local fileName=$3
	fileNameCheck "$fileName"

	printf "${InfoB}Run query at ${InfoBI}${hostName}${InfoB} in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostName 'configFile='${applicationDir}'app/config/parameters.yml && sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs` && sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs` && sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs` && sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs` && printf "'$sqlQuery'" | mysql --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase'
}

function sqlExportSymfony {
	local hostName=$1
	local applicationDir=$2
	local fileName=$3
	fileNameCheck "$fileName"

	printf "${InfoB}Export database at ${InfoBI}${hostMaster}${InfoB} host in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostName 'configFile='${applicationDir}'app/config/parameters.yml && sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs` && sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs` && sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs` && sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs` && mysqldump --routines --events --triggers --single-transaction --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase > ${HOME}/'${fileName}''
}

function sqlImportSymfony {
	local hostName=$1
	local applicationDir=$2
	local fileName=$3
	fileNameCheck "$fileName"

	printf "${InfoB}Import database at ${InfoBI}${hostName}${InfoB} host in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostName 'configFile='${applicationDir}'app/config/parameters.yml && sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs` && sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs` && sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs` && sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs` && mysql --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase < ${HOME}/'${fileName}''
}

function sqlExportMetsa {
	local hostName=$1
	local applicationDir=$2
	local fileName=$3
	fileNameCheck "$fileName"

	printf "${InfoB}Export database at ${InfoBI}${hostMaster}${InfoB} host in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostMaster 'configFile='${applicationDir}'class/Database.php && sqlHost=`cat ${configFile} | sed -n "s/^    const MYSQL_HOST = \"\(.*\)\";/\1/p" | xargs` && sqlUser=`cat ${configFile} | sed -n "s/^    const MYSQL_USER = \"\(.*\)\";/\1/p" | xargs` && sqlPass=`cat ${configFile} | sed -n "s/^    const MYSQL_PASS = \"\(.*\)\";/\1/p" | xargs` && sqlBase=`cat ${configFile} | sed -n "s/^    const MYSQL_DB = \"\(.*\)\";/\1/p" | xargs` && mysqldump --routines --events --triggers --single-transaction --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase > ${HOME}/'${fileName}''
}

function sqlImportMetsa {
	local hostName=$1
	local applicationDir=$2
	local fileName=$3
	fileNameCheck "$fileName"

	printf "${InfoB}Import database at ${InfoBI}${hostName}${InfoB} in ${InfoBI}${applicationDir}${InfoB} directory${Info}\n"
	ssh $hostName 'configFile='${applicationDir}'class/Database.php && sqlHost=`cat ${configFile} | sed -n "s/^    const MYSQL_HOST = \"\(.*\)\";/\1/p" | xargs` && sqlUser=`cat ${configFile} | sed -n "s/^    const MYSQL_USER = \"\(.*\)\";/\1/p" | xargs` && sqlPass=`cat ${configFile} | sed -n "s/^    const MYSQL_PASS = \"\(.*\)\";/\1/p" | xargs` && sqlBase=`cat ${configFile} | sed -n "s/^    const MYSQL_DB = \"\(.*\)\";/\1/p" | xargs` && mysql --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase < ${HOME}/'${fileName}''
}

