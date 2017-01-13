#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


_proxy="example-proxy-dev"
_host="example-server-dev"
_directory="dev"
_containerName="mysql55"
_database="example"


clear
programTitle "SQL dump on remote Symfony app via proxy and import to docker"

promptVariable proxy "Proxy" "$_proxy" 1 "$@"
promptVariable host "Host" "$_host" 2 "$@"
promptVariable directory "Directory" "$_directory" 3 "$@"
promptVariable containerName "Docker container name" "$_containerName" 4 "$@"
promptVariable database "Local database name" "$_database" 5 "$@"
datetime=`date "+%Y%m%d-%H%M%S"`
exportFileName="backup_${host}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/www/mysql/${containerName}/data/"
virtualDataDir="/var/lib/mysql/"
localScriptsDir=`dirname $0`"/"
localTriggerFile="${HOME}/www/mysql/${containerName}/data/"${database}".sql"
virtualTriggerFile="/var/lib/mysql/"${database}".sql"

confirmOrExit "Dump SQL on ${QuestionBI}${host}${Question} via ${QuestionBI}${proxy}${Question} from directory ${QuestionBI}${directory}${Question} and save on docker ${QuestionBI}${containerName}${Question} container to ${QuestionBI}${database}${Question} database?"

printf "${BBlue}Copy scripts to ${BIBlue}${proxy}${BBlue} proxy ${Blue} \n"
scp ${localScriptsDir}_base.sh ${proxy}:'${HOME}/_base.sh'
scp ${localScriptsDir}_colors.sh ${proxy}:'${HOME}/_colors.sh'
scp ${localScriptsDir}sql-dump-symfony.sh ${proxy}:'${HOME}/sql-dump-symfony.sh'
scp ${localScriptsDir}sql-dump-on-remote-symfony.sh ${proxy}:'${HOME}/sql-dump-on-remote-symfony.sh'
printf "${Color_Off}"

printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
ssh ${proxy} 'yes | bash ${HOME}/sql-dump-on-remote-symfony.sh '${host}' '${directory}' '${exportFileName}
printf "${Color_Off}"

printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from ${BIGreen}${host}${BGreen} host to ${BIGreen}local${BGreen} host ${Green} \n"
mkdir -p ${localDataDir}
cd ${localDataDir}
scp ${proxy}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
printf "${Color_Off}"

printf "${BRed}Cleanup ${BIRed}${proxy}${BRed} proxy ${Red} \n"
ssh ${proxy} 'rm '${remoteDataDir}${exportFileName}' ${HOME}/_base.sh ${HOME}/_colors.sh ${HOME}/sql-dump-symfony.sh ${HOME}/sql-dump-on-remote-symfony.sh'
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
