#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_remoteHost="example-server-dev"
_directory="dev"
_mysqlHost="mysql55"
_database="example"


## WELCOME
programTitle "SQL dump-n-import: from remote Symfony app to local/docker"


## VARIABLES
promptVariable remoteHost "Remote host name (from SSH config file)" "$_remoteHost" 1 "$@"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 2 "$@"
datetime=`date "+%Y%m%d-%H%M%S"`
exportFileName="backup_${remoteHost}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
promptVariable mysqlHost "Local MySQL machine name (or Docker container name)" "$_mysqlHost" 3 "$@"
if [ $_mysqlHost == "localhost" ];
then
	_isDocker=false
	promptVariable database "Local MySQL database name" "$_database" 4 "$@"
	localDataDir="${HOME}/backup/"
	localTriggerFile="${HOME}/www/database/"${database}".sql"
else
	_isDocker=true
	promptVariable database "Docker MySQL database name" "$_database" 4 "$@"
	localDataDir="${HOME}/www/mysql/${mysqlHost}/data/"
	localTriggerFile="${HOME}/www/mysql/${mysqlHost}/data/"${database}".sql"
	virtualDataDir="/var/lib/mysql/"
	virtualTriggerFile="/var/lib/mysql/"${database}".sql"
fi


## PROGRAM
confirmOrExit "Dump SQL on ${QuestionBI}${remoteHost}${Question} from directory ${QuestionBI}${directory}${Question} and save on docker ${QuestionBI}${mysqlHost}${Question} container to ${QuestionBI}${database}${Question} database?"

sourcedScriptsList+=('sql-dump-symfony.sh sql-dump-symfony.sh')
copyScriptsToHost "$remoteHost"

ssh ${remoteHost} 'yes | bash ${HOME}/sql-dump-symfony.sh '${directory}' '${exportFileName} 0

moveFileFromHostToLocal "$remoteHost" "$remoteDataDir" "$localDataDir" "$exportFileName"

removeScriptsFromHost "$remoteHost"

if [ $_isDocker == "true"]; then
	bash `dirname ${BASH_SOURCE}`/sql-import-docker.sh "$mysqlHost" "$database" "$exportFileName"
else
	bash `dirname ${BASH_SOURCE}`/sql-import-local.sh "$mysqlHost" "$database" "$exportFileName"
fi

programEnd
