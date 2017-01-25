#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_mysqlHost="mysql55"
_database="example"
datetime=`date "+%Y%m%d-%H%M%S"`
_exportFileName="backup_${datetime}.sql"


## WELCOME
programTitle "SQL import to local"


## VARIABLES
promptVariable exportFileName "Export file name" "$_exportFileName" 1 "$@"
promptVariable mysqlHost "Local MySQL machine name" "$_mysqlHost" 2 "$@"
promptVariable database "Local MySQL database name" "$_database" 3 "$@"

localDataDir="${HOME}/backup/"
localTriggerDir="${HOME}/www/database/"
triggerFileName=${database}".sql"



## PROGRAM
confirmOrExit "Import SQL to ${QuestionBI}${database}${Question} database at ${QuestionBI}${mysqlHost}${Question} mysql host from ${QuestionBI}${exportFileName}${Question} export file and ${QuestionBI}${triggerFileName}${Question} trigger file?"

printf "${InfoB}Import ${InfoBI}${exportFileName}${InfoB} export file to ${InfoBI}${database}${InfoB} database on local ${Info} \n"
mysql ${database} < ${localDataDir}${exportFileName}
printf "${Color_Off}"

if [ -f "${localTriggerDir}${triggerFileName}" ]; then
  printf "${InfoB}Execute ${InfoBI}${triggerFileName}${InfoB} trigger file  to ${InfoBI}${database}${InfoB} database on local ${Info} \n"
  mysql ${database} < ${localTriggerDir}${triggerFileName}
  printf "${Color_Off}"
fi

removeFileFromLocal "${localDataDir}" "${exportFileName}"

programEnd
