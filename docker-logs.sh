#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_docker_container_name="php55"


## WELCOME
program_title "Read Docker container logs"


## VARIABLES
prompt_variable docker_container_name "Container name" "${_docker_container_name}" 1 "$@"


## PROGRAM
if [[ $(docker inspect -f {{.State.Running}} ${docker_container_name}) == "false" ]]; then
	printf "${color_success}Starting container ${color_success_b}"
	docker start ${docker_container_name}
	printf "${color_off}"
fi

docker logs --follow --details --timestamps --tail 32 ${docker_container_name}

display_new_line
