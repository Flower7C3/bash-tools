#!/usr/bin/env bash

source `dirname $0`/_base.sh


localWwwPath=${HOME}/www/
localProjectPath=$(pwd)

dockerWwwPath=/var/www/
dockerProjectPath=${localProjectPath/$localWwwPath/$dockerWwwPath}

_containerName="php55"
_commandName="pwd"
_interactive="y"
_autoClose="n"

programTitle "Execute command on Docker container"

if [[ $localProjectPath == ${localWwwPath}* ]];
then

	printfln "You are in ${BIYellow}`pwd`${Color_Off} directory."

	promptVariable containerName "Container name" "${_containerName}" 1 "$@"
	promptVariable commandName "Command" "${_commandName}" 2 "$@"
	promptVariable interactive "Interactive" "${_interactive}" 3 "$@"
	promptVariable autoClose "Auto close" "${_autoClose}" 4 "$@"

	confirmOrExit "Execute ${BIYellow}${commandName}${Color_Off} command in ${BIYellow}${dockerProjectPath}${Color_Off} path of ${BIYellow}${containerName}${Color_Off} docker container?"

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

else

	printfln "You must be in ${BIYellow}${localWwwPath}*${Color_Off} path to run this command!"

fi

programEnd
