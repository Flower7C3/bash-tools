#!/usr/bin/env bash

source `dirname $0`/_base.sh


_host="example-server-dev"
_directory="dev"
_database="example"


clear
programTitle "SQL dump on remote Symfony app"

promptVariable host "Host [${BIYellow}${_host}${Color_Off}]"  "$_host" $1
promptVariable directory "Directory [${BIYellow}${_directory}${Color_Off}]"  "$_directory" $2
setVariable exportFileName "backup_${host}_`date "+%Y%m%d-%H%M%S"`.sql" $3

remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"
localScriptsDir=`dirname $0`"/"

confirmOrExit "${Color_Off}Dump sql on ${BIYellow}${host}${Color_Off} from directory ${BIYellow}${directory}${Color_Off}?"

printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
scp ${localScriptsDir}_base.sh ${host}:'${HOME}/_base.sh'
scp ${localScriptsDir}_colors.sh ${host}:'${HOME}/_colors.sh'
scp ${localScriptsDir}sql-dump-symfony.sh ${host}:'${HOME}/sql-dump-symfony.sh'
printf "${Color_Off}"

printf "${BGreen}Dump sql on ${BIGreen}${host}${BGreen} host ${Green} \n"
ssh ${host} '${HOME}/sql-dump-symfony.sh '${directory}' '${exportFileName}
printf "${Color_Off}"

printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} to local ${Green} \n"
mkdir -p ${localDataDir}
cd ${localDataDir}
scp ${host}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
printf "${Color_Off}"

printf "${BRed}Cleanup ${BIRed}${host}${BRed} host ${Red} \n"
ssh ${host} 'rm '${remoteDataDir}${exportFileName}' ${HOME}/_base.sh ${HOME}/_colors.${HOME}/sql-dump-symfony.sh'

programEnd
