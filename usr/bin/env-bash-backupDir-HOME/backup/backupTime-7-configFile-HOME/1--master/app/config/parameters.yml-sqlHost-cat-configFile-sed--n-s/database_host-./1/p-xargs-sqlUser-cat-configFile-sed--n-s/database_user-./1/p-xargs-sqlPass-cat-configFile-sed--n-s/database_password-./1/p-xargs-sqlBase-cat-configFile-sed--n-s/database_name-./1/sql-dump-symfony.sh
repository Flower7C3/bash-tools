#!/usr/bin/env bash

backupDir=${HOME}/backup/
backupTime=7
configFile=${HOME}/${1:-master}/app/config/parameters.yml

sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs`
sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs`
sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs`
sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs`

backupFile=${sqlBase}-`date "+%Y%m%d-%H%M%S"`.sql

mkdir -p ${backupDir}
mysqldump --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase > ${backupDir}${backupFile}

if [[ $backupTime > 0 ]]; then
        find ${backupDir} -mtime +${backupTime} -exec rm {} \; 
fi
