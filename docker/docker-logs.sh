#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../vendor/Flower7C3/bash-helpers/_base.sh


## CONFIG
_docker_container_name="php55"


## WELCOME
program_title "Read Docker container logs"


## VARIABLES
prompt_variable docker_container_name "Container name" "${_docker_container_name}" 1 "$@"


## PROGRAM
if [[ $(docker inspect -f {{.State.Running}} ${docker_container_name}) == "false" ]]; then
	printf "${COLOR_SUCCESS}Starting container ${COLOR_SUCCESS_B}"
	docker start ${docker_container_name}
	color_reset
fi

docker logs --follow --details --timestamps --tail 32 ${docker_container_name}

print_new_line
