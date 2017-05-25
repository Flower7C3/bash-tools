#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
backupDir=${HOME}/backup/


## WELCOME
programTitle "Mongo dump on Symfony app"


## VARIABLES
_directory="master"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 1 "$@"
configFile=${HOME}/${directory}/app/config/parameters.yml
mongoHost=`sed -n "s/\([ ]\{1,\}\)mongo_host:\(.*\)/\2/p" $configFile | xargs`
if [[ "$mongoHost" == '~' || "$mongoHost" == '' || "$mongoHost" == 'null' ]]; then
	mongoHost='localhost'
fi
mongoPort=`sed -n "s/\([ ]\{1,\}\)mongo_port:\(.*\)/\2/p" $configFile | xargs`
if [[ "$mongoPort" == '~' || "$mongoPort" == '' || "$mongoPort" == 'null' ]]; then
	mongoPort=27017
fi
mongoUser=`sed -n "s/\([ ]\{1,\}\)mongo_user:\(.*\)/\2/p" $configFile | xargs`
if [[ "$mongoUser" == '~' || "$mongoUser" == '' || "$mongoUser" == 'null' ]]; then
	mongoUser='root'
fi
mongoPass=`sed -n "s/\([ ]\{1,\}\)mongo_password:\(.*\)/\2/p" $configFile | xargs`
if [[ "$mongoPass" == '~' || "$mongoPass" == '' || "$mongoPass" == 'null' ]]; then
	mongoPass=''
fi
mongoBase=`sed -n "s/\([ ]\{1,\}\)mongo_database:\(.*\)/\2/p" $configFile | xargs`
_exportDirName="${mongoBase}-`date "+%Y%m%d-%H%M%S"`"
promptVariable exportDirName "Export dirname" "$_exportDirName" 2 "$@"
_exportFileName="${mongoBase}-`date "+%Y%m%d-%H%M%S"`.tar.gz"
promptVariable exportFileName "Export filename" "$_exportFileName" 3 "$@"
_backupTime=0
promptVariable backupTime "Backup time (days)" "$_backupTime" 4 "$@"


## PROGRAM
confirmOrExit "Dump Mongo from ${QuestionBI}${mongoUser}@${mongoHost}/${mongoBase}${QuestionB} base to ${QuestionBI}${exportFileName}${QuestionB} file?"

printf "${InfoB}Dumping database ${Info} \n"
mkdir -p ${backupDir}
mongodump --host ${mongoHost} --port ${mongoPort} --username ${mongoUser} --password ${mongoPass} --db ${mongoBase} --out ${backupDir} --gzip
(cd ${backupDir} && mv ${mongoBase} ${exportDirName})
(cd ${backupDir} && tar -zcvf ${backupDir}${exportFileName} ${exportDirName} && rm -rf ${exportDirName})

if [[ $backupTime > 0 ]]; then
	printf "${NoticeB}Clean old backups ${Notice} \n"
	find ${backupDir} -mtime +${backupTime} -exec rm {} \; 
fi

programEnd
