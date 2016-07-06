#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_proxy="example-proxy-dev"
_host="example-server-dev"
_directory="dev"
_localdirectory="lamp56"
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
  localdirectory=$4
else
  printf "${Color_Off}Local directory name [${BIYellow}${_localdirectory}${Color_Off}]: ${On_IGreen}"
  read -e input
  localdirectory=${input:-$_localdirectory}
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
localDataDir="${HOME}/Documents/${localdirectory}/"
virtualDataDir="/vagrant/"
localScriptsDir=`pwd`"/"
localTriggerFile="${HOME}/Documents/database/"${database}".sql"
virtualTriggerFile="/var/lib/mysql/"${database}".sql"

printf "Dump sql on ${BIYellow}${host}${Color_Off} via ${BIYellow}${proxy}${Color_Off} from directory ${BIYellow}${directory}${Color_Off} and save on virtual ${BIYellow}${localdirectory}${Color_Off} to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

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

  printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} to ${BIGreen}${database}${BGreen} database on virtual ${Green} \n"
  cd ${localDataDir}
  vagrant ssh -c "mysql "${database}" < "${virtualDataDir}${exportFileName}
  printf "${Color_Off}"

  if [ -f "${localTriggerFile}" ]; then
    printf "${BGreen}Execute trigger file ${BIGreen}${virtualTriggerFile}${BGreen} to ${BIGreen}${database}${BGreen} database on virtual ${Green} \n"
    vagrant ssh -c "mysql "${database}" < "${virtualTriggerFile}
    printf "${Color_Off}"
  fi

  printf "${BBRed}Cleanup localhost ${Red} \n"
  rm ${localDataDir}${exportFileName}
  printf "${Color_Off}"

fi
