#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_containerName="mongo3"
_mongoDatabase="example"
_exportDirName="backup_`date "+%Y%m%d-%H%M%S"`"
_exportFileName="backup_`date "+%Y%m%d-%H%M%S"`.tar.gz"


## WELCOME
programTitle "Mongo import to docker"


## VARIABLES
promptVariable containerName "Docker container name" "$_containerName" 1 "$@"
promptVariable mongoDatabase "Docker Mongo database name" "$_mongoDatabase" 2 "$@"

localDataDir="${HOME}/www/database/mongo/${containerName}/data/"
localTriggerDir="${HOME}/www/database/mongo/${containerName}/data/"
virtualDataDir="/data/db/"
virtualTriggerDir="/data/db/"
triggerFileName=${mongoDatabase}".json"

promptVariable exportDirName "Export dir name (from ${QuestionBI}${localDataDir}${QuestionB} path)" "$_exportDirName" 3 "$@"
promptVariable exportFileName "Export file name (from ${QuestionBI}${localDataDir}${QuestionB} path)" "$_exportFileName" 4 "$@"


## PROGRAM
confirmOrExit "Import Mongo to ${QuestionBI}${mongoDatabase}${Question} database at ${QuestionBI}${containerName}${Question} docker container from ${QuestionBI}${exportFileName}${Question} export file and ${QuestionBI}${triggerFileName}${Question} trigger file?"

printf "${InfoB}Import ${InfoBI}${exportFileName}${InfoB} export file to ${InfoBI}${mongoDatabase}${InfoB} database on docker ${Info} \n"
$(cd ${localDataDir} && tar xzf ${exportFileName})
docker exec -i ${containerName} sh -c 'exec mongorestore --drop --db '${mongoDatabase}' --gzip --dir '${virtualDataDir}${exportDirName}''
printf "${Color_Off}"

if [ -f "${localTriggerDir}${triggerFileName}" ]; then
	printf "${InfoB}Execute ${InfoBI}${triggerFileName}${InfoB} trigger file to ${InfoBI}${mongoDatabase}${InfoB} database on docker ${Info} \n"
	docker exec -t ${containerName} sh -c 'exec mongo < '${virtualTriggerDir}${triggerFileName}
	printf "${Color_Off}"
fi

remove_file_from_local "${localDataDir}" "${exportFileName}"
remove_dir_from_local "${localDataDir}" "${exportDirName}"

programEnd
