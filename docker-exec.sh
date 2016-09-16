#!/usr/bin/env bash

source `dirname $0`/_base.sh


localWwwPath=${HOME}/www/
localProjectPath=$(pwd)

dockerWwwPath=/var/www/
dockerProjectPath=${localProjectPath/$localWwwPath/$dockerWwwPath}

_containerName="php55"
_commandName="pwd"


programTitle "Execute command on Docker container"

if [[ $localProjectPath == ${localWwwPath}* ]];
then

	printfln "You are in ${BIYellow}`pwd`${Color_Off} directory."

	promptVariable containerName "Container name [${BIYellow}${_containerName}${Color_Off}]" "${_containerName}" $1
	promptVariable commandName "Command [${BIYellow}${_commandName}${Color_Off}]" "${_commandName}" $2

	confirmOrExit "Execute ${BIYellow}${commandName}${Color_Off} command in ${BIYellow}${dockerProjectPath}${Color_Off} path of ${BIYellow}${containerName}${Color_Off} docker container?"

	printf "${Color_Off}\n"
	docker start ${containerName}
	docker exec -ti ${containerName} bash -c "cd ${dockerProjectPath} && ${commandName}"

else

	printfln "You must be in ${BIYellow}${localWwwPath}*${Color_Off} path to run this command!"

fi

programEnd
