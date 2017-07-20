#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_containerName="mysql55"
_database="example"
_exportFileName="backup_`date "+%Y%m%d-%H%M%S"`.sql"


## WELCOME
programTitle "SQL import to docker"


## VARIABLES
promptVariable containerName "Docker container name" "$_containerName" 1 "$@"
promptVariable database "Docker MySQL database name" "$_database" 2 "$@"

localDataDir="${HOME}/www/database/mysql/${containerName}/data/"
localTriggerDir="${HOME}/www/database/mysql/${containerName}/data/"
virtualDataDir="/var/lib/mysql/"
virtualTriggerDir="/var/lib/mysql/"
triggerFileName=${database}".sql"

promptVariable exportFileName "Export file name (from ${QuestionBI}${localDataDir}${QuestionB} directory)" "$_exportFileName" 3 "$@"


## PROGRAM
confirmOrExit "Import SQL to ${QuestionBI}${database}${Question} database at ${QuestionBI}${containerName}${Question} docker container from ${QuestionBI}${exportFileName}${Question} export file and ${QuestionBI}${triggerFileName}${Question} trigger file?"

printf "${InfoB}Import ${InfoBI}${exportFileName}${InfoB} export file to ${InfoBI}${database}${InfoB} database on docker ${Info} \n"
docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualDataDir}${exportFileName}
printf "${Color_Off}"

if [ -f "${localTriggerDir}${triggerFileName}" ]; then
	printf "${InfoB}Execute ${InfoBI}${triggerFileName}${InfoB} trigger file to ${InfoBI}${database}${InfoB} database on docker ${Info} \n"
	docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualTriggerDir}${triggerFileName}
	printf "${Color_Off}"
fi

remove_file_from_local "${localDataDir}" "${exportFileName}"

programEnd
