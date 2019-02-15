#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh

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
_apache_version="2.4"
_apache_versions="no 2.2 2.4"
_php_version="7"
_php_versions="no 5.6 7.0 7.1 7.2 7.3"
_node_version="10"
_node_versions="no 6 8 10 11"
_mysql_version="5.7"
_mysql_versions="no 5.5 5.6 5.7 8.0"
_www_docroot="web"


## WELCOME
program_title "Docksal configuration warmup"


## VARIABLES
prompt_variable_not_null project_name "Project name (relative path)" "$_project_name" 1 "$@"
_domain_name=${project_name}
if [[ "$project_name" == "." ]]; then
    confirm_or_exit "Really want to install docksal in ${color_question_b}$(pwd)${color_question} directory?"
    _domain_name=$(basename `pwd`)
fi
prompt_variable_not domain_name "Domain name (without .docksal tld)" "$_domain_name" "." 2 "$@"
while true; do
    display_info "More informations on https://hub.docker.com/r/docksal/cli/"
    prompt_variable_fixed apache_version "Apache version ($_apache_versions)" "$_apache_version" "$_apache_versions" 3 "$@"
    prompt_variable_fixed php_version "PHP version ($_php_versions)" "$_php_version" "$_php_versions" 4 "$@"
    prompt_variable_fixed node_version "Node version ($_node_versions)" "$_node_version" "$_node_versions" 5 "$@"
    display_info "More informations on https://hub.docker.com/r/docksal/db/"
    prompt_variable_fixed mysql_version "MySQL version ($_mysql_versions)" "$_mysql_version" "$_mysql_versions" 6 "$@"
    docksal_stack=""
    if [[ "$apache_version" != "no" && "$php_version" != "no" && "$mysql_version" != "no" ]]; then
        docksal_stack="default"
    elif [[ "$apache_version" != "no" && "$php_version" != "no" && "$mysql_version" == "no" ]]; then
        docksal_stack="default-nodb"
    elif [[ "$apache_version" == "no" "$php_version" == "no" && "$mysql_version" == "no" && "$node_version" != "no" ]]; then
        docksal_stack="node"
    fi
    if [[ "$docksal_stack" == "" ]]; then
        _apache_version="$apache_version"
        _php_version="$php_version"
        _node_version="$node_version"
        _mysql_version="$mysql_version"
        set -- "${@:1:2}"
        display_error "Docksal stack not set. Please fix versions!"
        display_info "Possible configurations: ${color_info_h}Apache+PHP+MySQL${color_info_b} or ${color_info_h}Apache+PHP+Node+MySQL${color_info_b} or ${color_info_h}Apache+PHP+Node${color_info_b} or ${color_info_h}Node${color_info_b}."
    else
        display_info "Docksal stack set to ${color_info_h}$docksal_stack${color_info_b}."
        break
    fi
done

prompt_variable www_docroot "WWW dockroot" "$_www_docroot" 7 "$@"

## PROGRAM
confirm_or_exit "Build configuration?"

if [[ "$project_name" != "." ]]; then
    printf "${color_info_b}Create ${color_info_h}%s${color_info_b} project directory ${color_info} \n" "$project_name"
    mkdir -p ${project_name}
    cd ${project_name}
    printf "${color_off}"
fi

printf "${color_info_b}Create basic configuration \n"
fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
fin config set VIRTUAL_HOST="${domain_name}"
fin config set WEB_IMAGE="docksal/web:2.1-apache${apache_version}"
fin config set CLI_IMAGE="docksal/cli:2.5-php${php_version}"
if [[ "$mysql_version" != "no" ]]; then
	fin config set DB_IMAGE="docksal/db:1.1-mysql-${mysql_version}"
fi
if [[ "$node_version" != "no" ]]; then
    # see https://github.com/creationix/nvm#nvmrc
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
