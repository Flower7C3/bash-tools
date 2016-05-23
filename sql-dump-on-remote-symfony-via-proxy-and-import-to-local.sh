#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_proxy="example-proxy-dev"
_host="example-server-dev"
_branch="dev"
_database="example"

if [ $# -ge 1 ]
then
  proxy=$1
else
  printf "Proxy [${BIYellow}${_proxy}${Color_Off}]: ${On_IGreen}"
  read -e input
  proxy=${input:-$_proxy}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  host=$2
else
  printf "Host [${BIYellow}${_host}${Color_Off}]: ${On_IGreen}"
  read -e input
  host=${input:-$_host}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
  branch=$3
else
  printf "Branch [${BIYellow}${_branch}${Color_Off}]: ${On_IGreen}"
  read -e input
  branch=${input:-$_branch}
  printf "${Color_Off}"
fi

if [ $# -ge 4 ]
then
  database=$4
else
  printf "Local database name [${BIYellow}${_database}${Color_Off}]: ${On_IGreen}"
  read -e input
  database=${input:-$_database}
  printf "${Color_Off}"
fi

datetime=`date "+%Y%m%d-%H%M%S"`
exportFileName="backup_${host}_${branch}_${datetime}.sql"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"
vagrantDataDir="${HOME}/Documents/lamp/"
virtualDataDir="/vagrant/"
localScriptsDir=`pwd`"/"
triggerFile="database/"${database}".sql"

printf "Dump sql on ${BIYellow}${host}${Color_Off} via ${BIYellow}${proxy}${Color_Off} from branch ${BIYellow}${branch}${Color_Off} and save on virtual to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

	printf "${BBlue}Copy scripts to ${BIBlue}${proxy}${BBlue} proxy ${Blue} \n"
	scp ${localScriptsDir}colors.sh ${proxy}:'${HOME}/colors.sh'
  scp ${localScriptsDir}sql-dump-symfony.sh ${proxy}:'${HOME}/sql-dump-symfony.sh'
  scp ${localScriptsDir}sql-dump-on-remote-symfony.sh ${proxy}:'${HOME}/sql-dump-on-remote-symfony.sh'

	printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
	ssh ${proxy} 'yes | ${HOME}/sql-dump-on-remote-symfony.sh '${host}' '${branch}' '${exportFileName}

  printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from proxy to local ${Green} \n"
  mkdir ${localDataDir}
  cd ${localDataDir}
  scp ${proxy}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}
  mv ${localDataDir}${exportFileName} ${vagrantDataDir}${exportFileName}

	printf "${BRed}Cleanup ${BIRed}${proxy}${BRed} proxy ${Red} \n"
	ssh ${proxy} 'rm '${remoteDataDir}${exportFileName}
	ssh ${proxy} 'rm ${HOME}/colors.sh'
  ssh ${proxy} 'rm ${HOME}/sql-dump-symfony.sh'
  ssh ${proxy} 'rm ${HOME}/sql-dump-on-remote-symfony.sh'

  cd ${vagrantDataDir}
  printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} on virtual ${Green} \n"
  mysql ${database} < ${virtualDataDir}${exportFileName}

  if [ -f "${vagrantDataDir}${triggerFile}" ]; then
    printf "${BGreen}Import ${BIGreen}${triggerFile}${BGreen} on virtual ${Green} \n"
    ${database} < ${virtualDataDir}${triggerFile}
  fi

  printf "${BBRed}Cleanup localhost ${Red} \n"
  rm ${vagrantDataDir}${exportFileName}

  printf "${Color_Off}"

fi
