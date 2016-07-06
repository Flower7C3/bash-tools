#!/usr/bin/env bash

configFile=${HOME}/${1:-master}/app/config/parameters.yml

sqlHost=`cat $configFile | sed -n "s/^    database_host:\(.*\)/\1/p" | xargs`
sqlUser=`cat $configFile | sed -n "s/^    database_user:\(.*\)/\1/p" | xargs`
sqlPass=`cat $configFile | sed -n "s/^    database_password:\(.*\)/\1/p" | xargs`
sqlBase=`cat $configFile | sed -n "s/^    database_name:\(.*\)/\1/p" | xargs`

echo mysql --host=$sqlHost --user=$sqlUser --password=$sqlPass $sqlBase
