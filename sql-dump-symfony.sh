#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


backupDir=${HOME}/backup/
backupTime=${3:-7}
configFile=${HOME}/${1:-master}/app/config/parameters.yml

sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs`
sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs`
sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs`
sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs`

backupFileDefault=${sqlBase}-`date "+%Y%m%d-%H%M%S"`.sql
backupFile=${2:-$backupFileDefault}

programTitle "SQL dump on Symfony app"

printf "${BGreen}Dump SQL ${Green} \n"
mkdir -p ${backupDir}
mysqldump --host=$sqlHost --user=$sqlUser --password=$sqlPass --lock-tables=false $sqlBase > ${backupDir}${backupFile}

if [[ $backupTime > 0 ]]; then
	printf "${BRed}Clean old backups ${Red} \n"
	find ${backupDir} -mtime +${backupTime} -exec rm {} \; 
fi

programEnd
