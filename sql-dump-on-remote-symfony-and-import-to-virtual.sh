#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

_host="example-server-dev"
_branch="dev"
_database="example"

if [ $# -ge 1 ]
then
  host=$1
else
  printf "Host [${BIYellow}${_host}${Color_Off}]: ${On_IGreen}"
  read -e input
  host=${input:-$_host}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  branch=$2
else
  printf "Branch [${BIYellow}${_branch}${Color_Off}]: ${On_IGreen}"
  read -e input
  branch=${input:-$_branch}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
  database=$3
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

printf "Dump sql on ${BIYellow}${host}${Color_Off} from branch ${BIYellow}${branch}${Color_Off} and save on virtual to ${BIYellow}${database}${Color_Off} database? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

	printf "${BBlue}Copy scripts to ${BIBlue}${host}${BBlue} host ${Blue} \n"
	scp ${localScriptsDir}colors.sh ${host}:'${HOME}/colors.sh'
	scp ${localScriptsDir}sql-dump-symfony.sh ${host}:'${HOME}/sql-dump-symfony.sh'

	printf "${BGreen}Dump sql on ${BIGreen}${host}${BGreen} host ${Green} \n"
	ssh ${host} '${HOME}/sql-dump-symfony.sh '${branch}' '${exportFileName}

	printf "${BGreen}Copy ${BIGreen}${exportFileName}${BGreen} from host to local ${Green} \n"
  mkdir ${localDataDir}
  cd ${localDataDir}
	scp ${host}:${remoteDataDir}${exportFileName} ${localDataDir}${exportFileName}

	printf "${BRed}Cleanup ${BIRed}${host}${BRed} host ${Red} \n"
	ssh ${host} 'rm '${remoteDataDir}${exportFileName}
	ssh ${host} 'rm ${HOME}/colors.sh'
	ssh ${host} 'rm ${HOME}/sql-dump-symfony.sh'

  mv ${localDataDir}${exportFileName} ${vagrantDataDir}${exportFileName}

	cd ${vagrantDataDir}
  printf "${BGreen}Import ${BIGreen}${exportFileName}${BGreen} on virtual ${Green} \n"
  vagrant ssh -c "mysql "${database}" < "${virtualDataDir}${exportFileName}

  if [ -f "${vagrantDataDir}${triggerFile}" ]; then
    printf "${BGreen}Import ${BIGreen}${triggerFile}${BGreen} on virtual ${Green} \n"
    vagrant ssh -c "mysql "${database}" < "${virtualDataDir}${triggerFile}
  fi

	printf "${BBRed}Cleanup localhost ${Red} \n"
	rm ${vagrantDataDir}${exportFileName}

  printf "${Color_Off}"

fi
