#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh

## CONFIG
docksal_db_version="1.1"
docksal_example_dir="$(dirname ${BASH_SOURCE})/blueprint/docksal/"
_project_name="example_$(date "+%Y%m%d_%H%M%S")"
_application_stack="custom"
_application_stacks="custom php php-nodb node symfony4 drupal8"
_apache_version="2.4"
_apache_versions="no 2.4"
_php_version="7.4"
_php_versions="no 5.6 7.0 7.1 7.2 7.3 7.4"
_node_version="12"
_node_versions="no 6 8 10 11 12 13"
_mysql_version="5.7"
_mysql_versions="no 5.5 5.6 5.7 8.0"
_mysql_import="no"
_java_version="no"
_java_versions="no 8"
_www_docroot="docroot"
_symfony_config="no"
symfony4_git_path="https://github.com/docksal/example-symfony-skeleton.git"
drupal8_git_path="https://github.com/docksal/drupal8.git"

function copy_file() {
    local src_file_name=$1
    local dst_file_name=${2:-$src_file_name}
    local source_file_path=${docksal_example_dir}${src_file_name}
    local destination_file_path=.docksal/${dst_file_name}
    mkdir -p $(dirname ${destination_file_path})
    cp ${source_file_path} ${destination_file_path}
    printf "${COLOR_DEFAULT_I}Copied file from ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} to ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} ${COLOR_DEFAULT_I}\n" "$src_file_name" "$dst_file_name"
}

## WELCOME
program_title "Docksal configuration warmup"

## VARIABLES
display_info "Configure ${COLOR_INFO_H}project${COLOR_INFO_B} properties"
prompt_variable_not_null project_name "Project name (lowercase alphanumeric, underscore, and hyphen)" "$_project_name" 1 "$@"
_domain_name=${project_name}
if [[ "$project_name" == "." ]]; then
    confirm_or_exit "Really want to install docksal in ${COLOR_QUESTION_B}$(pwd)${COLOR_QUESTION} directory?"
    _domain_name=$(basename $(pwd))
fi
prompt_variable_not domain_name "Domain name (without .docksal tld)" "$_domain_name" "." 2 "$@"
domain_name="${domain_name}.docksal"
domain_url="http://${domain_name}"

prompt_variable_fixed application_stack "Application stack" "$_application_stack" "$_application_stacks" 3 "$@"
if [[ "$application_stack" == "node" ]]; then
    _mysql_version="no"
fi

if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" || "$application_stack" == "node" ]]; then
    while true; do
        apache_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" ]]; then
            display_info "Configure ${COLOR_INFO_H}web${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/web/${COLOR_INFO_B})"
            prompt_variable_fixed apache_version "Apache version on web container" "$_apache_version" "$_apache_versions"
        fi
        display_info "Configure ${COLOR_INFO_H}cli${COLOR_INFO_B} container (read more on${COLOR_INFO_H}https://hub.docker.com/r/docksal/cli/${COLOR_INFO_B})"
        php_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" ]]; then
            prompt_variable_fixed php_version "PHP version on cli container" "$_php_version" "$_php_versions"
        fi
        node_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" || "$application_stack" == "node" ]]; then
            prompt_variable_fixed node_version "Node version on cli container" "$_node_version" "$_node_versions"
        fi
        java_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" || "$application_stack" == "node" ]]; then
            prompt_variable_fixed java_version "JAVA version on cli container" "$_java_version" "$_java_versions"
        fi
        prompt_variable www_docroot "WWW docroot (place where will be index file)" "$_www_docroot"
        mysql_version="no"
        mysql_import="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "node" ]]; then
            display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO_B} container (read more on${COLOR_INFO_H}https://hub.docker.com/r/docksal/db/${COLOR_INFO_B})"
            prompt_variable_fixed mysql_version "MySQL version on db container" "$_mysql_version" "$_mysql_versions"
            if [[ "$mysql_version" != "no" ]]; then
                prompt_variable_fixed mysql_import "Init example MySQL db" "$_mysql_import" "yes no"
            fi
        fi
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
            display_info "Possible configurations: ${COLOR_INFO_H}Apache+PHP+MySQL${COLOR_INFO_B} or ${COLOR_INFO_H}Apache+PHP+Node+MySQL${COLOR_INFO_B} or ${COLOR_INFO_H}Apache+PHP+Node${COLOR_INFO_B} or ${COLOR_INFO_H}Node${COLOR_INFO_B}."
        else
            display_info "Docksal stack set to ${COLOR_INFO_H}$docksal_stack${COLOR_INFO_B}."
            break
        fi
    done
else
    apache_version="no"
    php_version="no"
    node_version="no"
    java_version="no"
    mysql_version="no"
    docksal_stack="no"
fi

if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" && "$php_version" != "no" ]]; then
    prompt_variable_fixed symfony_config "Init example Symfony Framework config" "$_symfony_config" "yes no"
else
    symfony_config="no"
fi

# PROGRAM
confirm_or_exit "Build Docksal configuration?"

if [[ "$project_name" != "." ]]; then
    display_info "Create ${COLOR_INFO_H}$project_name${COLOR_INFO_B} project directory"
    mkdir -p ${project_name}
    cd ${project_name}
    color_reset
fi
project_path=$(realpath .)

if [[ -d .docksal ]]; then
    display_error "Docksal config already exists!"
    confirm_or_exit "Override Docksal configuration?"
fi

if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" ]]; then
    display_info "Create basic configuration"
    fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
    docksal_web_image="docksal/apache:${apache_version}"
    fin config set WEB_IMAGE="$docksal_web_image"
    if [[ "$php_version" == "5.6" || "$php_version" == "7.0" ]]; then
        docksal_cli_image="docksal/cli:php${php_version}"
    else
        docksal_cli_image="docksal/cli:edge-php${php_version}"
    fi
    fin config set CLI_IMAGE="$docksal_cli_image"
    if [[ "$mysql_version" != "no" ]]; then
        fin config set DB_IMAGE="docksal/db:${docksal_db_version}-mysql-${mysql_version}"
    fi
    if [[ "$node_version" != "no" ]]; then
        display_info "More info about ${COLOR_INFO_H}.nvmrc${COLOR_INFO_B} file on ${COLOR_INFO_H}https://github.com/creationix/nvm#nvmrc"
        echo ${node_version} >.nvmrc
    fi
    if [[ "$mysql_import" == "yes" || "$java_version" != "no" ]]; then
        echo "services:" >>.docksal/docksal.yml
    fi
else
    display_info "Import preconfigured repository"
    if [[ "$application_stack" == "symfony4" ]]; then
        git clone ${symfony4_git_path} .
    elif [[ "$application_stack" == "drupal8" ]]; then
        git clone ${drupal8_git_path} .
    fi
fi
fin config set VIRTUAL_HOST="${domain_name}"
color_reset

display_info "Add custom commands"
if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" ]]; then
    copy_file "commands/init"
    copy_file "commands/init-site"
    sed -i '' -e "s/symfony_base_url=\"\(.*\)\"/symfony_base_url=\""$(echo "$domain_url" | sed 's/\//\\\//g')"\"/g" .docksal/commands/init-site
fi
if [[ "$node_version" != "no" ]]; then
    copy_file "commands/gulp"
    copy_file "commands/npm"
fi
if [[ "$symfony_config" != "no" ]]; then
    copy_file "commands/console2"
    copy_file "commands/console"
fi
color_reset

if [[ "$mysql_import" == "yes" ]]; then
    display_info "Import custom db into ${COLOR_INFO_H}db${COLOR_INFO_B} container"
    mkdir -p .docksal/services/db/dump/
    copy_file "services/db/dump/dump.sql"
    cat ${docksal_example_dir}docksal.yml/db-custom-data.yml >>.docksal/docksal.yml
    color_reset
fi

if [[ "$node_version" != "no" ]]; then
    display_info "Prepare node in ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    sed -i.bak "s/#uncomment#nvm_install/nvm_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#npm_install/npm_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#gulp_build/gulp_build/g" .docksal/commands/init-site
    rm .docksal/commands/init-site.bak
    color_reset
fi

if [[ "$java_version" != "no" ]]; then
    display_info "Add ${COLOR_INFO_H}JAVA${COLOR_INFO_B} to ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/Dockerfile-with-java" "services/cli/Dockerfile"
    sed -i '' -e "s/FROM \(.*\)/FROM "$(echo "$docksal_cli_image" | sed 's/\//\\\//g')"/g" .docksal/services/cli/Dockerfile
    cat ${docksal_example_dir}docksal.yml/cli-with-java.yml >>.docksal/docksal.yml
    color_reset
fi

if [[ "$symfony_config" != "no" ]]; then
    display_info "Add ${COLOR_INFO_H}Symfony parameters${COLOR_INFO_B} to ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/parameters.yaml" "services/cli/parameters.yaml"
    symfony_secret=$(date +%s%N | shasum | base64 | head -c 32)
    symfony_base_url=$(printf ${domain_url} | sed 's:/:\\/:g')
    sed -i.bak "s/secret: \(.*\)/secret: "${symfony_secret}"/g" .docksal/services/cli/parameters.yaml
    sed -i.bak "s/base_url: \(.*\)/base_url: "${symfony_base_url}"/g" .docksal/services/cli/parameters.yaml
    rm .docksal/services/cli/parameters.yaml.bak
    sed -i.bak "s/#uncomment#copy_settings_file/copy_settings_file/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#symlinks_create/symlinks_create/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#cache_clean/cache_clean/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#composer_install/composer_install/g" .docksal/commands/init-site
    sed -i.bak "s/#uncomment#symfony_assets_build/symfony_assets_build/g" .docksal/commands/init-site
    rm .docksal/commands/init-site.bak
    copy_file "services/cli/htaccess" "../${www_docroot}/.htaccess.docksal"
    copy_file "services/cli/app_docksal.php" "../${www_docroot}/app_docksal.php"
    color_reset
fi

display_success "Docksal configuration is ready."

confirm_or_exit "Initialize docker project?" "You can init project manually with ${COLOR_INFO_H}fin init${COLOR_INFO_B} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO_B} directory."
display_info "Initialize docker project (executing ${COLOR_INFO_H}fin init${COLOR_INFO_B} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO_B} directory.)"
fin init
color_reset

print_new_line
