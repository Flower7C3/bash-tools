#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
localWwwPath=${HOME}/www/
localProjectPath=$(pwd)

dockerWwwPath=/var/www/
dockerProjectPath=${localProjectPath/$localWwwPath/$dockerWwwPath}

_containerName="php55"
_commandName="pwd"
_interactive="y"
_autoClose="n"


## WELCOME
programTitle "Execute command on Docker container"
if [[ $localProjectPath == ${localWwwPath}* ]];
then
	printfln "You are in ${InfoBI}`pwd`${Color_Off} directory."
else
	printfln "${Error}You must be in ${ErrorBI}${localWwwPath}*${Error} path to run this command!${Color_Off}"
	programError
fi


## VARIABLES
promptVariable containerName "Container name" "${_containerName}" 1 "$@"
promptVariable commandName "Command" "${_commandName}" 2 "$@"
promptVariable interactive "Interactive" "${_interactive}" 3 "$@"
promptVariable autoClose "Auto close" "${_autoClose}" 4 "$@"


## PROGRAM
confirmOrExit "Execute ${QuestionBI}${commandName}${Question} command in ${QuestionBI}${dockerProjectPath}${Question} path of ${QuestionBI}${containerName}${Question} docker container?"

if [[ $(docker inspect -f {{.State.Running}} ${containerName}) == "false" ]]; then
	printf "${Green}Starting container ${BGreen}"
	docker start ${containerName}
	printf "${Color_Off}"
fi

if [[ "$interactive" = "y" ]]; then
	docker exec -ti ${containerName} bash -c "cd ${dockerProjectPath} && ${commandName}"
else
	docker exec ${containerName} bash -c "cd ${dockerProjectPath} && ${commandName}"
fi

if [[ "$autoClose" == "y" ]]; then
	printf "${Red}Stoping container ${BRed}"
	docker stop ${containerName}
	printf "${Color_Off}"
fi

programEnd
