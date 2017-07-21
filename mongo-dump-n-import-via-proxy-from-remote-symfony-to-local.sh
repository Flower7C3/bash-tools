#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_proxyHost="example-proxy-dev"
_remoteHost="example-server-dev"
_directory="dev"
_mongoHost="mongo3"
_database="example"


## WELCOME
programTitle "Mongo dump-n-import: from remote Symfony app via proxy to local/docker"


## VARIABLES
promptVariable proxyHost "Proxy name (from SSH config file)" "$_proxyHost" 1 "$@"
promptVariable remoteHost "Remote host name (from SSH config file)" "$_remoteHost" 2 "$@"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)" "$_directory" 3 "$@"
exportDirName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`"
exportFileName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`.tar.gz"
remoteDataDir='${HOME}/backup/'
promptVariable mongoHost "Local Mongo machine name (or Docker container name)" "$_mongoHost" 4 "$@"
if [ $_mongoHost == "localhost" ];
then
	_isDocker=false
	promptVariable database "Local Mongo database name" "$_database" 5 "$@"
	localDataDir="${HOME}/backup/"
else
	_isDocker=true
	promptVariable database "Docker Mongo database name" "$_database" 5 "$@"
	localDataDir="${HOME}/www/database/mongo/${mongoHost}/data/"
fi


## PROGRAM
confirmOrExit "Dump Mongo on ${QuestionBI}${remoteHost}${Question} via ${QuestionBI}${proxyHost}${Question} from directory ${QuestionBI}${directory}${Question} and save on local/docker ${QuestionBI}${mongoHost}${Question} container to ${QuestionBI}${database}${Question} database?"

sourcedScriptsList+=('mongo-dump-symfony.sh mongo-dump-symfony.sh' 'mongo-dump-remote-symfony.sh mongo-dump-remote-symfony.sh')
copy_scripts_to_host "$proxyHost"

ssh ${proxyHost} 'yes | bash ${HOME}/mongo-dump-remote-symfony.sh '${remoteHost}' '${directory}' '${exportDirName}' '${exportFileName}

move_file_from_host_to_local "$proxyHost" "$remoteDataDir" "$localDataDir" "$exportFileName"

remove_scripts_from_host "$proxyHost"

if [ $_isDocker == "true" ]; then
	yes | bash `dirname ${BASH_SOURCE}`/mongo-import-docker.sh "$mongoHost" "$database" "${exportDirName}" "$exportFileName"
else
	yes | bash `dirname ${BASH_SOURCE}`/mongo-import-local.sh "$mongoHost" "$database" "${exportDirName}" "$exportFileName"
fi

programEnd
