#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
backupDir=${HOME}/backup/


## WELCOME
programTitle "SQL dump on Symfony app"


## VARIABLES
_directory="master"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 1 "$@"
configFile=${HOME}/${directory}/app/config/parameters.yml
sqlHost=$(sed -n "s/\([ ]\{1,\}\)database_host:\(.*\)/\2/p" $configFile | xargs)
if [[ "$sqlHost" == "~" || "$sqlHost" == "" || "$sqlHost" == "null" ]]; then
	sqlHost='localhost'
fi
sqlPort=$(sed -n "s/\([ ]\{1,\}\)database_port:\(.*\)/\2/p" $configFile | xargs)
if [[ "$sqlPort" == "~" || "$sqlPort" == "" || "$sqlPort" == "null" ]]; then
	sqlPort=3306
fi
sqlUser=$(sed -n "s/\([ ]\{1,\}\)database_user:\(.*\)/\2/p" $configFile | xargs)
if [[ "$sqlUser" == "~" || "$sqlUser" == "" || "$sqlUser" == "null" ]]; then
	sqlUser='root'
fi
sqlPass=$(sed -n "s/\([ ]\{1,\}\)database_password:\(.*\)/\2/p" $configFile | xargs)
if [[ "$sqlPass" == "~" || "$sqlPass" == "" || "$sqlPass" == "null" ]]; then
	sqlPass=''
fi
sqlBase=$(sed -n "s/\([ ]\{1,\}\)database_name:\(.*\)/\2/p" $configFile | xargs)
_exportFileName=${sqlBase}-$(date "+%Y%m%d-%H%M%S").sql
promptVariable exportFileName "Export filename" "$_exportFileName" 2 "$@"
_backupTime=0
promptVariable backupTime "Backup time (days)" "$_backupTime" 3 "$@"


## PROGRAM
confirmOrExit "Dump SQL from ${QuestionBI}${sqlUser}@${sqlHost}/${sqlBase}${QuestionB} base to ${QuestionBI}${exportFileName}${QuestionB} file?"

printf "${InfoB}Dumping database ${Info} \n"
mkdir -p ${backupDir}
mysqldump --host=${sqlHost} --port=${sqlPort} --user=${sqlUser} --password=${sqlPass} --skip-lock-tables ${sqlBase} > ${backupDir}${exportFileName}

if [[ $backupTime > 0 ]]; then
	printf "${NoticeB}Clean old backups ${Notice} \n"
	find ${backupDir} -mtime +${backupTime} -exec rm {} \; 
fi

programEnd
