#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
local_www_path=${HOME}/www/
local_project_path=$(pwd)

docker_www_path=/var/www/
docker_project_path=${local_project_path/$local_www_path/$docker_www_path}

_docker_container_name="php55"
_commandName="pwd"
_interactive="y"
_auto_close="n"


## WELCOME
program_title "Execute command on Docker container"
if [[ ${local_project_path} == ${local_www_path}* ]];
then
	display_info "You are in ${COLOR_INFO_H}`pwd`${COLOR_INFO} directory."
else
	display_error "You must be in ${COLOR_ERROR_H}${local_www_path}*${COLOR_ERROR_B} path to run this command!"
	program_error
fi


## VARIABLES
prompt_variable docker_container_name "Container name" "${_docker_container_name}" 1 "$@"
prompt_variable commandName "Command" "${_commandName}" 2 "$@"
prompt_variable_fixed interactive "Interactive" "${_interactive}" "y n" 3 "$@"
prompt_variable_fixed auto_close "Auto close" "${_auto_close}" "y n" 4 "$@"


## PROGRAM
confirm_or_exit "Execute ${COLOR_QUESTION_H}${commandName}${COLOR_QUESTION} command in ${COLOR_QUESTION_H}${docker_project_path}${COLOR_QUESTION} path of ${COLOR_QUESTION_H}${docker_container_name}${COLOR_QUESTION} docker container?"

if [[ $(docker inspect -f {{.State.Running}} ${docker_container_name}) == "false" ]]; then
	printf "${COLOR_SUCCESS}Starting container ${COLOR_SUCCESS_B}"
	docker start ${docker_container_name}
	color_reset
fi

if [[ "$interactive" = "y" ]]; then
	docker exec -ti ${docker_container_name} bash -c "cd ${docker_project_path} && ${commandName}"
else
	docker exec ${docker_container_name} bash -c "cd ${docker_project_path} && ${commandName}"
fi

if [[ "$auto_close" == "y" ]]; then
	printf "${COLOR_ERROR}Stoping container ${COLOR_ERROR_B}"
	docker stop ${docker_container_name}
	color_reset
fi

print_new_line
