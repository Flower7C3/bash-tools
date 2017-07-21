#!/usr/bin/env bash

configFile=${HOME}/${1:-master}/app/config/parameters.yml

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

echo "mysql --host=${sqlHost} --port=${sqlPort} --user=${sqlUser} --password=${sqlPass} ${sqlBase}"
