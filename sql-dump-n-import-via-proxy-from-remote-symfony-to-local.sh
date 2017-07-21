#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_proxyHost="example-proxy-dev"
_remoteHost="example-server-dev"
_directory="dev"
_mysqlHost="mysql55"
_database="example"


## WELCOME
programTitle "SQL dump-n-import: from remote Symfony app via proxy to local/docker"


## VARIABLES
promptVariable proxyHost "Proxy name (from SSH config file)" "$_proxyHost" 1 "$@"
promptVariable remoteHost "Remote host name (from SSH config file)" "$_remoteHost" 2 "$@"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 3 "$@"
datetime=$(date "+%Y%m%d-%H%M%S")
exportFileName="backup_${remoteHost}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
promptVariable mysqlHost "Local MySQL machine name (or Docker container name)" "$_mysqlHost" 4 "$@"
if [ $_mysqlHost == "localhost" ];
then
	_isDocker=false
	promptVariable database "Local MySQL database name" "$_database" 5 "$@"
	localDataDir="${HOME}/backup/"
else
	_isDocker=true
	promptVariable database "Docker MySQL database name" "$_database" 5 "$@"
	localDataDir="${HOME}/www/database/mysql/${mysqlHost}/data/"
fi


## PROGRAM
confirmOrExit "Dump SQL on ${QuestionBI}${remoteHost}${Question} via ${QuestionBI}${proxyHost}${Question} from directory ${QuestionBI}${directory}${Question} and save on local/docker ${QuestionBI}${mysqlHost}${Question} container to ${QuestionBI}${database}${Question} database?"

sourcedScriptsList+=('sql-dump-symfony.sh sql-dump-symfony.sh' 'sql-dump-remote-symfony.sh sql-dump-remote-symfony.sh')
copy_scripts_to_host "$proxyHost"

ssh ${proxyHost} 'yes | bash ${HOME}/sql-dump-remote-symfony.sh '${remoteHost}' '${directory}' '${exportFileName}

move_file_from_host_to_local "$proxyHost" "$remoteDataDir" "$localDataDir" "$exportFileName"

remove_scripts_from_host "$proxyHost"

if [ $_isDocker == "true" ]; then
	yes | bash $(dirname ${BASH_SOURCE})/sql-import-docker.sh "$mysqlHost" "$database" "$exportFileName"
else
	yes | bash $(dirname ${BASH_SOURCE})/sql-import-local.sh "$mysqlHost" "$database" "$exportFileName"
fi

programEnd
