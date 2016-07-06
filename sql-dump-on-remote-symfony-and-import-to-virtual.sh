#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_host="example-server-dev"
_directory="dev"
_localdirectory="lamp56"
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
  localdirectory=$3
else
  printf "${Color_Off}Local directory name [${BIYellow}${_localdirectory}${Color_Off}]: ${On_IGreen}"
  read -e input
  localdirectory=${input:-$_localdirectory}
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
localDataDir="${HOME}/Documents/${localdirectory}/"
virtualDataDir="/vagrant/"
localScriptsDir=`pwd`"/"
localTriggerFile="${HOME}/Documents/database/"${database}".sql"
virtualTriggerFile="/var/lib/mysql/"${database}".sql"

printf "${Color_Off}Dump sql on ${BIYellow}${host}${Color_Off} from directory ${BIYellow}${directory}${Color_Off} and save on virtual ${BIYellow}${localdirectory}${Color_Off} to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

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

  printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} on virtual ${Green} \n"
  cd ${localDataDir}
  vagrant ssh -c "mysql "${database}" < "${virtualDataDir}${exportFileName}
  printf "${Color_Off}"

  if [ -f "${localTriggerFile}" ]; then
    printf "${BGreen}Execute trigger file ${BIGreen}${virtualTriggerFile}${BGreen} on virtual ${Green} \n"
    vagrant ssh -c "mysql "${database}" < "${virtualTriggerFile}
    printf "${Color_Off}"
  fi

	printf "${BBRed}Cleanup localhost ${Red} \n"
	rm ${localDataDir}${exportFileName}
  printf "${Color_Off}"

fi
