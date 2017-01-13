#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


_host="example-server-dev"
_directory="dev"
_database="example"


clear
programTitle "SQL dump on remote Symfony app"

promptVariable host "Host"  "$_host" 1 "$@"
promptVariable directory "Directory"  "$_directory" 2 "$@"
promptVariable exportFileName "Export filename" "backup_${host}_`date "+%Y%m%d-%H%M%S"`.sql" 3 "$@"

remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"
localScriptsDir=`dirname $0`"/"

confirmOrExit "Dump SQL on ${QuestionBI}${host}${Question} host from ${QuestionBI}${directory}${Question} directory?"

printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
scp ${localScriptsDir}_base.sh ${host}:'${HOME}/_base.sh'
scp ${localScriptsDir}_colors.sh ${host}:'${HOME}/_colors.sh'
scp ${localScriptsDir}sql-dump-symfony.sh ${host}:'${HOME}/sql-dump-symfony.sh'
printf "${Color_Off}"

printf "${BGreen}Dump SQL on ${BIGreen}${host}${BGreen} host ${Green} \n"
ssh ${host} 'bash ${HOME}/sql-dump-symfony.sh '${directory}' '${exportFileName} 0
printf "${Color_Off}"

printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from ${BIGreen}${host}${BGreen} host to ${BIGreen}local${BGreen} host ${Green} \n"
mkdir -p ${localDataDir}
cd ${localDataDir}
scp ${host}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
printf "${Color_Off}"

printf "${BRed}Cleanup ${BIRed}${host}${BRed} host ${Red} \n"
ssh ${host} 'rm '${remoteDataDir}${exportFileName}' ${HOME}/_base.sh ${HOME}/_colors.sh ${HOME}/sql-dump-symfony.sh'

programEnd
