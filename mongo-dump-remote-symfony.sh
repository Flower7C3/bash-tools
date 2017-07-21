#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_remoteHost="example-server-dev"
_directory="dev"
remoteDataDir='${HOME}/backup/'
localDataDir="${HOME}/backup/"


## WELCOME
programTitle "Mongo dump on remote Symfony app"


## VARIABLES
promptVariable remoteHost "Remote host name (from SSH config file)"  "$_remoteHost" 1 "$@"
_exportDirName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`"
_exportFileName="backup_${remoteHost}_`date "+%Y%m%d-%H%M%S"`.tar.gz"
promptVariable directory "Remote symfony directory (relative to "'${HOME}'" directory)"  "$_directory" 2 "$@"
promptVariable exportDirName "Export dirname" "$_exportDirName" 3 "$@"
promptVariable exportFileName "Export filename" "$_exportFileName" 4 "$@"


## PROGRAM
confirmOrExit "Dump Mongo on ${QuestionBI}${remoteHost}${Question} host from ${QuestionBI}${directory}${Question} directory?"

sourcedScriptsList+=('mongo-dump-symfony.sh mongo-dump-symfony.sh')
copy_scripts_to_host "$remoteHost"

ssh ${remoteHost} 'yes | bash ${HOME}/mongo-dump-symfony.sh '${directory}' '${exportDirName}' '${exportFileName} 0

move_file_from_host_to_local "${remoteHost}" "${remoteDataDir}" "${localDataDir}" "${exportFileName}"

remove_scripts_from_host "$remoteHost"

programEnd
