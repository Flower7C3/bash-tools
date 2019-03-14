#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
docksal_web_version="2.1"
docksal_cli_version="2.6"
docksal_db_version="1.1"
docksal_example_dir="$(dirname ${BASH_SOURCE})/docksal/"
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
_mysql_import="no"
_java_version="no"
_java_versions="no 8"
_www_docroot="web"
_symfony_config="no"

function copy_file {
    local src_file_name=$1
    local dst_file_name=${2:-$src_file_name}
    local source_file_path=${docksal_example_dir}${src_file_name}
    local destination_file_path=.docksal/${dst_file_name}
    mkdir -p $(dirname ${destination_file_path})
    cp ${source_file_path} ${destination_file_path}
    printf "${color_default_i}Copied file from ${color_default_h}%s${color_default_i} to ${color_default_h}%s${color_default_i} ${color_default_i}\n" "$src_file_name" "$dst_file_name"
}


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
domain_name="${domain_name}.docksal"
domain_url="http://${domain_name}"
while true; do
    display_info "More info about ${color_info_h}web${color_info_b} container on ${color_info_h}https://hub.docker.com/r/docksal/web/${color_info_b}"
    prompt_variable_fixed apache_version "Apache version" "$_apache_version" "$_apache_versions" 3 "$@"
    display_info "More info about ${color_info_h}cli${color_info_b} container on ${color_info_h}https://hub.docker.com/r/docksal/cli/${color_info_b}"
    prompt_variable_fixed php_version "PHP version" "$_php_version" "$_php_versions" 4 "$@"
    prompt_variable_fixed node_version "Node version" "$_node_version" "$_node_versions" 5 "$@"
    prompt_variable_fixed java_version "JAVA version" "$_java_version" "$_java_versions" 6 "$@"
    display_info "More info about ${color_info_h}db${color_info_b} container on ${color_info_h}https://hub.docker.com/r/docksal/db/${color_info_b}"
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

prompt_variable www_docroot "WWW docroot (place where will be index file)" "$_www_docroot" 8 "$@"
prompt_variable_fixed mysql_import "Init example MySQL db" "$_mysql_import" "yes no" 9 "$@"
prompt_variable_fixed symfony_config "Init example Symfony Framework config" "$_symfony_config" "yes no" 10 "$@"

# PROGRAM
confirm_or_exit "Build Docksal configuration?"

if [[ "$project_name" != "." ]]; then
    display_info "Create ${color_info_h}$project_name${color_info_b} project directory"
    mkdir -p ${project_name}
    cd ${project_name}
    printf "${color_off}"
fi

if [[ -d .docksal ]]; then
    display_error "Docksal config already exists!"
    confirm_or_exit "Override Docksal configuration?"
fi

display_info "Create basic configuration"
fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
fin config set VIRTUAL_HOST="${domain_name}"
docksal_web_image="docksal/web:${docksal_web_version}-apache${apache_version}"
fin config set WEB_IMAGE="$docksal_web_image"
docksal_cli_image="docksal/cli:${docksal_cli_version}-php${php_version}"
fin config set CLI_IMAGE="$docksal_cli_image"
if [[ "$mysql_version" != "no" ]]; then
	fin config set DB_IMAGE="docksal/db:${docksal_db_version}-mysql-${mysql_version}"
fi
if [[ "$node_version" != "no" ]]; then
    display_info "More info about ${color_info_h}.nvmrc${color_info_b} file on ${color_info_h}https://github.com/creationix/nvm#nvmrc"
	echo ${node_version} > .nvmrc
fi
if [[ "$mysql_import" == "yes" || "$java_version" != "no" ]]; then
    echo "services:" >> .docksal/docksal.yml
fi
printf "${color_off}"

display_info "Add custom commands"
copy_file "commands/init"
copy_file "commands/init-site"
sed -i '' -e "s/symfony_base_url=\"\(.*\)\"/symfony_base_url=\""$(echo "$domain_url" | sed 's/\//\\\//g' )"\"/g" .docksal/commands/init-site
if [[ "$node_version" != "no" ]]; then
    copy_file "commands/gulp"
    copy_file "commands/npm"
fi
if [[ "$symfony_config" != "no" ]]; then
    copy_file "commands/console2"
    copy_file "commands/console"
fi
printf "${color_off}"

if [[ "$mysql_import" == "yes" ]]; then
    display_info "Import custom db into ${color_info_h}db${color_info_b} container"
    mkdir -p .docksal/dist/db/
    copy_file "dist/db/dump.sql"
    cat ${docksal_example_dir}docksal.yml/db-custom-data.yml >> .docksal/docksal.yml
    printf "${color_off}"
fi

if [[ "$node_version" != "no" ]]; then
    display_info "Prepare node in ${color_info_h}cli${color_info_b} container"
    sed -i.bak "s/#uncomment#nvm_install/nvm_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#npm_install/npm_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#gulp_build/gulp_build/g" .docksal/commands/init-site
    rm .docksal/commands/init-site.bak
    printf "${color_off}"
fi

if [[ "$java_version" != "no" ]]; then
    display_info "Add ${color_info_h}JAVA${color_info_b} to ${color_info_h}cli${color_info_b} container"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/Dockerfile-with-java" "services/cli/Dockerfile"
    sed -i '' -e "s/FROM \(.*\)/FROM "$(echo "$docksal_cli_image" | sed 's/\//\\\//g' )"/g" .docksal/services/cli/Dockerfile
    cat ${docksal_example_dir}docksal.yml/cli-with-java.yml >> .docksal/docksal.yml
    printf "${color_off}"
fi

if [[ "$symfony_config" != "no" ]]; then
    display_info "Add ${color_info_h}Symfony parameters${color_info_b} to ${color_info_h}cli${color_info_b} container"
    mkdir -p .docksal/dist/cli/
    copy_file "dist/cli/parameters.yml" "dist/cli/parameters.yml"
    symfony_secret=$(date +%s%N | shasum | base64 | head -c 32)
    symfony_base_url=$(printf ${domain_url} | sed 's:/:\\/:g')
    sed -i.bak "s/secret: \(.*\)/secret: "${symfony_secret}"/g" .docksal/dist/cli/parameters.yml
    sed -i.bak "s/base_url: \(.*\)/base_url: "${symfony_base_url}"/g" .docksal/dist/cli/parameters.yml
    rm .docksal/dist/cli/parameters.yml.bak
    sed -i.bak "s/#uncomment#copy_settings_file/copy_settings_file/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#symlinks_create/symlinks_create/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#cache_clean/cache_clean/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#composer_install/composer_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#symfony_assets_build/symfony_assets_build/g" .docksal/commands/init-site
    rm .docksal/commands/init-site.bak
    copy_file "dist/cli/htaccess" "../${www_docroot}/.htaccess.docksal"
    copy_file "dist/cli/app_docksal.php" "../${www_docroot}/app_docksal.php"
    printf "${color_off}"
fi


display_info "Initialize docker project (execute ${color_info_h}fin init${color_info_b} command)""
fin init
printf "${color_off}"


program_end
