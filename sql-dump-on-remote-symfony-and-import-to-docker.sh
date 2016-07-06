#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_host="example-server-dev"
_directory="dev"
_containerName="mysql55"
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
  containerName=$3
else
  printf "${Color_Off}Docker container name [${BIYellow}${_containerName}${Color_Off}]: ${On_IGreen}"
  read -e input
  containerName=${input:-$_containerName}
  printf "${Color_Off}"
fi

if [ $# -ge 4 ]
then
  database=$4
else
  printf "${Color_Off}Local database name [${BIYellow}${_database}${Color_Off}]: ${On_IGreen}"
  read -e input
  database=${input:-$_database}
  printf "${Color_Off}"
fi

datetime=`date "+%Y%m%d-%H%M%S"`
exportFileName="backup_${host}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/Documents/database/"
virtualDataDir="/var/lib/mysql/"
localScriptsDir=`pwd`"/"
localTriggerFile="${HOME}/Documents/database/"${database}".sql"
virtualTriggerFile="/var/lib/mysql/"${database}".sql"

printf "${Color_Off}Dump sql on ${BIYellow}${host}${Color_Off} from directory ${BIYellow}${directory}${Color_Off} and save on docker ${BIYellow}${containerName}${Color_Off} container to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

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

	printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from host to local ${Green} \n"
  mkdir ${localDataDir}
  cd ${localDataDir}
	scp ${host}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
  printf "${Color_Off}"

	printf "${BRed}Cleanup ${BIRed}${host}${BRed} host ${Red} \n"
	ssh ${host} 'rm '${remoteDataDir}${exportFileName}
	ssh ${host} 'rm ${HOME}/colors.sh'
	ssh ${host} 'rm ${HOME}/sql-dump-symfony.sh'
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
  printf "${Color_Off}"

fi
