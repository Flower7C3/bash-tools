#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
docker_container_name=$1

## PROGRAM
if [[ $(docker inspect -f {{.State.Running}} ${docker_container_name}) == "false" ]]; then
    printf "${COLOR_SUCCESS}Starting container ${COLOR_SUCCESS_B}"
    docker start ${docker_container_name}
    color_reset
fi

docker exec -ti ${docker_container_name} bash
