#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_host="example-server-dev"
_directory="dev"
_database="example"

if [ $# -ge 1 ]
then
  host=$1
else
  printf "${Color_Off}Host [${BIYellow}${_host}${Color_Off}]: ${On_IGreen}"
  read -e input
  host=${input:-$_host}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  directory=$2
else
  printf "${Color_Off}Directory [${BIYellow}${_directory}${Color_Off}]: ${On_IGreen}"
  read -e input
  directory=${input:-$_directory}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
	exportFileName=$3
else
	datetime=`date "+%Y%m%d-%H%M%S"`
	exportFileName="backup_${host}_${datetime}.sql"
fi

remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"
localScriptsDir=`pwd`"/"

printf "${Color_Off}Dump sql on ${BIYellow}${host}${Color_Off} from directory ${BIYellow}${directory}${Color_Off}? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

	printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
	scp ${localScriptsDir}colors.sh ${host}:'${HOME}/colors.sh'
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
	ssh ${host} 'rm '${remoteDataDir}${exportFileName}
	ssh ${host} 'rm ${HOME}/colors.sh'
	ssh ${host} 'rm ${HOME}/sql-dump-symfony.sh'
	printf "${Color_Off}"

fi
