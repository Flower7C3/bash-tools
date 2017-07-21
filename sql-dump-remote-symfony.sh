#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_remoteHost="example-server-dev"
_directory="dev"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"


## WELCOME
programTitle "SQL dump on remote Symfony app"


## VARIABLES
promptVariable remoteHost "Remote host name (from SSH config file)"  "$_remoteHost" 1 "$@"
_exportFileName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`.sql"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 2 "$@"
promptVariable exportFileName "Export filename" "${_exportFileName}" 3 "$@"


## PROGRAM
confirmOrExit "Dump SQL on ${QuestionBI}${remoteHost}${Question} host from ${QuestionBI}${directory}${Question} directory?"

sourcedScriptsList+=('sql-dump-symfony.sh sql-dump-symfony.sh')
copy_scripts_to_host "$remoteHost"

ssh ${remoteHost} 'yes | bash ${HOME}/sql-dump-symfony.sh '${directory}' '${exportFileName} 0

move_file_from_host_to_local "${remoteHost}" "${remoteDataDir}" "${localDataDir}" "${exportFileName}"

remove_scripts_from_host "$remoteHost"

programEnd
