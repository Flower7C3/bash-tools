#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


_containerName="php55"

programTitle "Read Docker container logs"

promptVariable containerName "Container name" "${_containerName}" 1 "$@"

if [[ $(docker inspect -f {{.State.Running}} ${containerName}) == "false" ]]; then
	printf "${Green}Starting container ${BGreen}"
	docker start ${containerName}
	printf "${Color_Off}"
fi

docker logs --follow --details --timestamps --tail 32 ${containerName}

programEnd
