#!/usr/bin/env bash

source `dirname $0`/_base.sh


_host="example-server-dev"
_directory="dev"
_containerName="mysql55"
_database="example"


clear
programTitle "SQL dump on remote Symfony app and import to docker"

promptVariable host "Host" "$_host" 1 "$@"
promptVariable directory "Directory" "$_directory" 2 "$@"
promptVariable containerName "Docker container name" "$_containerName" 3 "$@"
promptVariable database "Local database name" "$_database" 4 "$@"

datetime=`date "+%Y%m%d-%H%M%S"`
exportFileName="backup_${host}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/www/database/"
virtualDataDir="/var/lib/mysql/"
localScriptsDir=`dirname $0`"/"
localTriggerFile="${HOME}/www/database/"${database}".sql"
virtualTriggerFile="/var/lib/mysql/"${database}".sql"

confirmOrExit "Dump sql on ${BIYellow}${host}${Color_Off} from directory ${BIYellow}${directory}${Color_Off} and save on docker ${BIYellow}${containerName}${Color_Off} container to ${BIYellow}${database}${Color_Off} database?"

printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
scp ${localScriptsDir}_base.sh ${host}:'${HOME}/_base.sh'
scp ${localScriptsDir}_colors.sh ${host}:'${HOME}/_colors.sh'
scp ${localScriptsDir}sql-dump-symfony.sh ${host}:'${HOME}/sql-dump-symfony.sh'
printf "${Color_Off}"

printf "${BGreen}Dump sql on ${BIGreen}${host}${BGreen} host ${Green} \n"
ssh ${host} '${HOME}/sql-dump-symfony.sh '${directory}' '${exportFileName}
printf "${Color_Off}"

printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from host to local ${Green} \n"
mkdir ${localDataDir}
cd ${localDataDir}
scp ${host}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
printf "${Color_Off}"

printf "${BRed}Cleanup ${BIRed}${host}${BRed} host ${Red} \n"
ssh ${host} 'rm '${remoteDataDir}${exportFileName}' ${HOME}/_base.sh ${HOME}/_colors.sh ${HOME}/sql-dump-symfony.sh'
printf "${Color_Off}"

printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} to ${BIGreen}${database}${BGreen} database on docker ${Green} \n"
docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualDataDir}${exportFileName}
printf "${Color_Off}"

if [ -f "${localTriggerFile}" ]; then
  printf "${BGreen}Execute trigger file ${BIGreen}${virtualTriggerFile}${BGreen} to ${BIGreen}${database}${BGreen} database on virtual ${Green} \n"
  docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualTriggerFile}
  printf "${Color_Off}"
fi

printf "${BBRed}Cleanup localhost ${Red} \n"
rm ${localDataDir}${exportFileName}

programEnd
