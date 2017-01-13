#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


containerName=$1


if [[ $(docker inspect -f {{.State.Running}} ${containerName}) == "false" ]]; then
	printf "${Green}Starting container ${BGreen}"
	docker start ${containerName}
	printf "${Color_Off}"
fi

docker exec -ti ${containerName} bash
