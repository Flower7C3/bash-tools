#!/usr/bin/env bash

host="${1:-example-server-dev}"
branch="${2:-dev}"
datetime=`date "+%Y%m%d-%H%M%S"`
exportFileLocal="${HOME}/export_${host}_${datetime}.sql"
exportFileRemote="~/export.sql"

echo "Connect to $host and dump database to export file $exportFileRemote"
ssh $host 'configFile=${HOME}/'${branch}'/app/config/parameters.yml && sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs` && sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs` && sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs` && sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs` && mysqldump --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase > ${HOME}/export.sql'

echo "Copy remote export file $exportFileRemote to local export file $exportFileLocal"
scp $host:$exportFileRemote $exportFileLocal

echo "Remove remote export file"
ssh $host 'rm ${HOME}/export.sql'
