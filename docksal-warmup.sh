#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh

function copy_file {
	local src_file_name=$1
	local dst_file_name=${2:-$src_file_name}
	local source_file_path=${_script_dir_path}/docksal/${src_file_name}
	local destination_file_path=.docksal/${dst_file_name}
	mkdir -p $(dirname ${destination_file_path})
	cp ${source_file_path} ${destination_file_path}
	printf "${color_default_i}Copied file from ${color_default_h}%s${color_default_i} to ${color_default_h}%s${color_default_i} ${color_default_i}\n" "$src_file_name" "$dst_file_name"
}

## CONFIG
_script_dir_path=$(dirname ${BASH_SOURCE})/
_project_name="example_$(date "+%Y%m%d_%H%M%S")"
_project_name="test"
_apache_version="2.4"
_apache_versions="no 2.2 2.4"
_php_version="7.2"
_php_versions="no 5.6 7.0 7.1 7.2 7.3"
_node_version="10"
_node_versions="no 6 8 10 11"
_mysql_version="5.7"
_mysql_versions="no 5.5 5.6 5.7 8.0"
_java_version="no"
_java_versions="no 8"
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
    display_info "More informations on ${color_info_h}https://hub.docker.com/r/docksal/web/${color_info_b}"
    prompt_variable_fixed apache_version "Apache version" "$_apache_version" "$_apache_versions" 3 "$@"
    display_info "More informations on ${color_info_h}https://hub.docker.com/r/docksal/cli/${color_info_b}"
    prompt_variable_fixed php_version "PHP version" "$_php_version" "$_php_versions" 4 "$@"
    prompt_variable_fixed node_version "Node version" "$_node_version" "$_node_versions" 5 "$@"
    prompt_variable_fixed java_version "JAVA version" "$_java_version" "$_java_versions" 6 "$@"
    display_info "More informations on ${color_info_h}https://hub.docker.com/r/docksal/db/${color_info_b}"
    prompt_variable_fixed mysql_version "MySQL version" "$_mysql_version" "$_mysql_versions" 7 "$@"
    docksal_stack=""
    if [[ "$apache_version" != "no" && "$php_version" != "no" && "$mysql_version" != "no" ]]; then
        docksal_stack="default"
    elif [[ "$apache_version" != "no" && "$php_version" != "no" && "$mysql_version" == "no" ]]; then
        docksal_stack="default-nodb"
    elif [[ "$apache_version" == "no" && "$php_version" == "no" && "$mysql_version" == "no" && "$node_version" != "no" ]]; then
        docksal_stack="node"
    fi
    if [[ "$docksal_stack" == "" ]]; then
        _apache_version="$apache_version"
        _php_version="$php_version"
        _node_version="$node_version"
        _java_version="$java_version"
        _mysql_version="$mysql_version"
        set -- "${@:1:2}"
        display_error "Docksal stack not set. Please fix versions!"
        display_info "Possible configurations: ${color_info_h}Apache+PHP+MySQL${color_info_b} or ${color_info_h}Apache+PHP+Node+MySQL${color_info_b} or ${color_info_h}Apache+PHP+Node${color_info_b} or ${color_info_h}Node${color_info_b}."
    else
        display_info "Docksal stack set to ${color_info_h}$docksal_stack${color_info_b}."
        break
    fi
done

prompt_variable www_docroot "WWW dockroot" "$_www_docroot" 8 "$@"

## PROGRAM
confirm_or_exit "Build Docksal configuration?"

if [[ "$project_name" != "." ]]; then
    printf "${color_info_b}Create ${color_info_h}%s${color_info_b} project directory ${color_default_i} \n" "$project_name"
    mkdir -p ${project_name}
    cd ${project_name}
    printf "${color_off}"
fi

if [[ -d .docksal ]]; then
    display_error "Docksal config already exists!"
    confirm_or_exit "Override Docksal configuration?"
fi

printf "${color_info_b}Create basic configuration \n"
fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
fin config set VIRTUAL_HOST="${domain_name}"
docksal_web_image="docksal/web:2.1-apache${apache_version}"
fin config set WEB_IMAGE="$docksal_web_image"
docksal_cli_image="docksal/cli:2.5-php${php_version}"
fin config set CLI_IMAGE="$docksal_cli_image"
if [[ "$mysql_version" != "no" ]]; then
	fin config set DB_IMAGE="docksal/db:1.1-mysql-${mysql_version}"
fi
if [[ "$node_version" != "no" ]]; then
    # see https://github.com/creationix/nvm#nvmrc
	echo ${node_version} > .nvmrc
fi
echo "services:" >> .docksal/docksal.yml
printf "${color_off}"

printf "${color_info_b}Add custom commands ${color_default_i} \n"
if [[ "$node_version" != "no" ]]; then
	copy_file "commands/gulp"
	copy_file "commands/npm"
fi
copy_file "commands/init"
copy_file "commands/init-site"
printf "${color_off}"

if [[ "$java_version" != "no" ]]; then
    printf "${color_info_b}Add ${color_info_bi}JAVA${color_info_b} to ${color_info_bi}cli${color_info_b} container ${color_default_i} \n"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/Dockerfile-with-java" "services/cli/Dockerfile"
    sed -i '' -e "s/FROM \(.*\)/FROM "$(echo "$docksal_cli_image" | sed 's/\//\\\//g' )"/g" .docksal/services/cli/Dockerfile
    cat ${_script_dir_path}/docksal/docksal-cli-java.yml.part >> .docksal/docksal.yml
    printf "${color_off}"
fi

printf "${color_info_b}Start project (execute ${color_info_h}%s${color_info_b} command) ${color_default_i} \n" "fin start"
fin init
printf "${color_off}"


program_end
