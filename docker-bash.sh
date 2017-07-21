#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
docker_container_name=$1


## PROGRAM
if [[ $(docker inspect -f {{.State.Running}} ${docker_container_name}) == "false" ]]; then
	printf "${color_success}Starting container ${color_success_b}"
	docker start ${docker_container_name}
	printf "${color_off}"
fi

docker exec -ti ${docker_container_name} bash
