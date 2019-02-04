#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh

function read_file_to_file {
	local source_file_name=$1
	local destination_file_name=$2
	mkdir -p $(dirname ${destination_file_name})
	echo -e "$(eval "echo -e \"`<${source_file_name}`\"")" >> ${destination_file_name}
}

function copy_command {
	local command_name=$1
	local source_file_name=${_script_dir_path}/docksal/commands/${command_name}
	local destination_file_name=.docksal/commands/${command_name}
	mkdir -p $(dirname ${destination_file_name})
	cp ${source_file_name} ${destination_file_name}
	echo "$command_name"
}

## CONFIG
_script_dir_path=$(dirname ${BASH_SOURCE})/
_project_name="example_$(date "+%Y%m%d_%H%M%S")"
_project_name="test"
_php_version="7.1"
_php_versions="5.6 7.0 7.1 7.2 7.3"
_mysql_version="no"
_mysql_versions="no 5.5 5.6 5.7 8.0"
_node_version="10"
_node_versions="no 6 8 10 11"
_www_docroot="web"


## WELCOME
program_title "Docksal init"


## VARIABLES
prompt_variable project_name "Project name" "$_project_name" 1 "$@"
prompt_variable_fixed php_version "PHP version ($_php_versions)" "$_php_version" "$_php_versions" 2 "$@"
prompt_variable_fixed mysql_version "MySQL version ($_mysql_versions)" "$_mysql_version" "$_mysql_versions" 3 "$@"
prompt_variable_fixed node_version "Node version ($_node_versions)" "$_node_version" "$_node_versions" 4 "$@"
prompt_variable www_docroot "WWW dockroot" "$_www_docroot" 5 "$@"


## PROGRAM
confirm_or_exit "Build configuration?"

printf "${color_info_b}Create ${color_info_h}%s${color_info_b} project directory ${color_info} \n" "$project_name"
rm -rf ${project_name}
mkdir -p ${project_name}
cd ${project_name}/
printf "${color_off}"

printf "${color_info_b}Create basic configuration \n"
docksal_stack="default"
if [[ "$mysql_version" == "no" ]]; then
	docksal_stack="default-nodb"
fi
fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
fin config set CLI_IMAGE="docksal/cli:2.5-php${php_version}"
if [[ "$mysql_version" != "no" ]]; then
	fin config set DB_IMAGE="docksal/db:1.1-mysql-${mysql_version}"
fi
if [[ "$node_version" != "no" ]]; then
	echo ${node_version} > .nvmrc
fi
printf "${color_off}"

printf "${color_info_b}Add custom commands ${color_info} \n"
if [[ "$node_version" != "no" ]]; then
	copy_command "gulp"
	copy_command "npm"
fi
copy_command "init"
copy_command "init-site"
printf "${color_off}"

printf "${color_info_b}Start project (execute ${color_info_h}%s${color_info_b} command) ${color_info} \n" "fin start"
fin init
printf "${color_off}"


program_end