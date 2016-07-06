#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_proxy="example-proxy-dev"
_host="example-server-dev"
_directory="dev"
_containerName="mysql55"
_database="example"

if [ $# -ge 1 ]
then
  proxy=$1
else
  printf "${Color_Off}Proxy [${BIYellow}${_proxy}${Color_Off}]: ${On_IGreen}"
  read -e input
  proxy=${input:-$_proxy}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  host=$2
else
  printf "${Color_Off}Host [${BIYellow}${_host}${Color_Off}]: ${On_IGreen}"
  read -e input
  host=${input:-$_host}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
  directory=$3
else
  printf "${Color_Off}Directory [${BIYellow}${_directory}${Color_Off}]: ${On_IGreen}"
  read -e input
  directory=${input:-$_directory}
  printf "${Color_Off}"
fi

if [ $# -ge 4 ]
then
  containerName=$4
else
  printf "${Color_Off}Docker container name [${BIYellow}${_containerName}${Color_Off}]: ${On_IGreen}"
  read -e input
  containerName=${input:-$_containerName}
  printf "${Color_Off}"
fi

if [ $# -ge 5 ]
then
  database=$5
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

printf "${Color_Off}Dump sql on ${BIYellow}${host}${Color_Off} via ${BIYellow}${proxy}${Color_Off} from directory ${BIYellow}${directory}${Color_Off} and save on docker ${BIYellow}${containerName}${Color_Off} container to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

	printf "${BBlue}Copy scripts to ${BIBlue}${proxy}${BBlue} proxy ${Blue} \n"
	scp ${localScriptsDir}colors.sh ${proxy}:'${HOME}/colors.sh'
  scp ${localScriptsDir}sql-dump-symfony.sh ${proxy}:'${HOME}/sql-dump-symfony.sh'
  scp ${localScriptsDir}sql-dump-on-remote-symfony.sh ${proxy}:'${HOME}/sql-dump-on-remote-symfony.sh'
  printf "${Color_Off}"

	printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
	ssh ${proxy} 'yes | ${HOME}/sql-dump-on-remote-symfony.sh '${host}' '${directory}' '${exportFileName}
  printf "${Color_Off}"

  printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from proxy to local ${Green} \n"
  mkdir -p ${localDataDir}
  cd ${localDataDir}
  scp ${proxy}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
  printf "${Color_Off}"

	printf "${BRed}Cleanup ${BIRed}${proxy}${BRed} proxy ${Red} \n"
	ssh ${proxy} 'rm '${remoteDataDir}${exportFileName}
	ssh ${proxy} 'rm ${HOME}/colors.sh'
  ssh ${proxy} 'rm ${HOME}/sql-dump-symfony.sh'
  ssh ${proxy} 'rm ${HOME}/sql-dump-on-remote-symfony.sh'
  printf "${Color_Off}"

  printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} on docker ${Green} \n"
  docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualDataDir}${exportFileName}
  printf "${Color_Off}"

  if [ -f "${localTriggerFile}" ]; then
    printf "${BGreen}Execute trigger file ${BIGreen}${virtualTriggerFile}${BGreen} on virtual ${Green} \n"
    docker exec -i ${containerName} sh -c 'exec mysql -p${MYSQL_ROOT_PASSWORD} '${database}' < '${virtualTriggerFile}
    printf "${Color_Off}"
  fi

  printf "${BBRed}Cleanup localhost ${Red} \n"
  # rm ${localDataDir}${exportFileName}
  printf "${Color_Off}"

fi
