#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_mongoHost="localhost"
_mongoDatabase="example"
_exportDirName="backup_`date "+%Y%m%d-%H%M%S"`"
_exportFileName="backup_`date "+%Y%m%d-%H%M%S"`.tar.gz"


## WELCOME
programTitle "SQL import to local"


## VARIABLES
promptVariable mongoHost "Mongo host" "$_mongoHost" 1 "$@"
promptVariable mongoDatabase "Mongo database name" "$_mongoDatabase" 2 "$@"

localDataDir="${HOME}/backup/"
localTriggerDir="${HOME}/www/database/"
triggerFileName=${mongoDatabase}".json"

promptVariable exportDirName "Export dir name (from ${QuestionBI}${localDataDir}${QuestionB} path)" "$_exportDirName" 3 "$@"
promptVariable exportFileName "Export file name (from ${QuestionBI}${localDataDir}${QuestionB} path)" "$_exportFileName" 4 "$@"



## PROGRAM
confirmOrExit "Import SQL to ${QuestionBI}${mongoDatabase}${Question} database at ${QuestionBI}${mysqlHost}${Question} mysql host from ${QuestionBI}${exportFileName}${Question} export file and ${QuestionBI}${triggerFileName}${Question} trigger file?"

printf "${InfoB}Import ${InfoBI}${exportFileName}${InfoB} export file to ${InfoBI}${mongoDatabase}${InfoB} database on local ${Info} \n"
$(cd ${localDataDir} && tar xzf ${exportFileName})
mongorestore --host ${mongoHost} --drop --db ${mongoDatabase} --gzip --dir ${localDataDir}${exportDirName}
printf "${Color_Off}"

if [ -f "${localTriggerDir}${triggerFileName}" ]; then
  printf "${InfoB}Execute ${InfoBI}${triggerFileName}${InfoB} trigger file to ${InfoBI}${mongoDatabase}${InfoB} database on local ${Info} \n"
  mongo --host ${mongoHost} < ${localTriggerDir}${triggerFileName}
  printf "${Color_Off}"
fi

removeFileFromLocal "${localDataDir}" "${exportFileName}"
removeDirFromLocal "${localDataDir}" "${exportDirName}"

programEnd
