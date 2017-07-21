#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_remoteHost="example-server-dev"
_directory="dev"
_mongoHost="mongo3"
_database="example"


## WELCOME
programTitle "Mongo dump-n-import: from remote Symfony app to local/docker"


## VARIABLES
promptVariable remoteHost "Remote host name (from SSH config file)" "$_remoteHost" 1 "$@"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 2 "$@"
exportDirName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`"
exportFileName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`.tar.gz"
remoteDataDir='${HOME}/backup/'
promptVariable mongoHost "Local Mongo machine name (or Docker container name)" "$_mongoHost" 3 "$@"
if [ $_mongoHost == "localhost" ];
then
	_isDocker=false
	promptVariable database "Local Mongo database name" "$_database" 4 "$@"
	localDataDir="${HOME}/backup/"
else
	_isDocker=true
	promptVariable database "Docker Mongo database name" "$_database" 4 "$@"
	localDataDir="${HOME}/www/database/mongo/${mongoHost}/data/"
fi


## PROGRAM
confirmOrExit "Dump Mongo on ${QuestionBI}${remoteHost}${Question} from directory ${QuestionBI}${directory}${Question} and save on docker ${QuestionBI}${mongoHost}${Question} container to ${QuestionBI}${database}${Question} database?"

sourcedScriptsList+=('mongo-dump-symfony.sh mongo-dump-symfony.sh')
copy_scripts_to_host "$remoteHost"

ssh ${remoteHost} 'yes | bash ${HOME}/mongo-dump-symfony.sh '${directory}' '${exportDirName}' '${exportFileName} 0

move_file_from_host_to_local "$remoteHost" "$remoteDataDir" "$localDataDir" "$exportFileName"

remove_scripts_from_host "$remoteHost"

if [ $_isDocker == "true"]; then
	yes | bash `dirname ${BASH_SOURCE}`/mongo-import-docker.sh "$mongoHost" "$database" "${exportDirName}" "$exportFileName"
else
	yes | bash `dirname ${BASH_SOURCE}`/mongo-import-local.sh "$mongoHost" "$database" "${exportDirName}" "$exportFileName"
fi

programEnd
