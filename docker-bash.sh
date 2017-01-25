#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
containerName=$1


## PROGRAM
if [[ $(docker inspect -f {{.State.Running}} ${containerName}) == "false" ]]; then
	printf "${Green}Starting container ${BGreen}"
	docker start ${containerName}
	printf "${Color_Off}"
fi

docker exec -ti ${containerName} bash
