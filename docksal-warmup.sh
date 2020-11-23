#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh

## CONFIG
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
_db_versions="no mysql mariadb"
_db_version="mariadb"
_mysql_version="5.7"
_mysql_versions="5.5 5.6 5.7 8.0"
_mariadb_version="10.3"
_mariadb_versions="5.5 10.0 10.1 10.2 10.3"
_db_import="yes"
_java_version="no"
_java_versions="no 8"
_www_docroot="docroot"
_symfony_config="no"
_drupal_config="no"
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

function append_file() {
    local src_file_name=$1
    local dst_file_name=$2
    local source_file_path=${docksal_example_dir}${src_file_name}
    local destination_file_path=.docksal/${dst_file_name}
    cat ${source_file_path} >> ${destination_file_path}
    printf "${COLOR_DEFAULT_I}Added file from ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} to ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} ${COLOR_DEFAULT_I}\n" "$src_file_name" "$dst_file_name"
}
function replace_in_file(){
    local file_path="$1"
    local text_from="$2"
    local text_to="$3"
    if [[ ! -f $file_path ]]; then
        touch $file_path
    fi
    sed -i '' -e "s/"$text_from"/"$text_to"/g" $file_path
    printf "${COLOR_DEFAULT_I}Replaced in file ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} from ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} to ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} ${COLOR_DEFAULT_I}\n" "$file_path" "$text_from" "$text_to"
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

display_info "Configure application containers (read more on ${COLOR_INFO_H}https://docs.docksal.io/stack/images-versions/${COLOR_INFO_B})"
prompt_variable_fixed application_stack "Application stack" "$_application_stack" "$_application_stacks" 3 "$@"
if [[ "$application_stack" == "node" ]]; then
    _db_version="no"
fi

if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" || "$application_stack" == "node" ]]; then
    while true; do
        apache_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" ]]; then
            display_info "Configure ${COLOR_INFO_H}web${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/web/${COLOR_INFO_B})"
            prompt_variable_fixed apache_version "Apache version on web container" "$_apache_version" "$_apache_versions"
        fi
        display_info "Configure ${COLOR_INFO_H}cli${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/cli/${COLOR_INFO_B})"
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
        db_version="no"
        db_import="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "node" ]]; then
            display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/db/${COLOR_INFO_B})"
            prompt_variable_fixed db_version "DB version on db container" "$_db_version" "$_db_versions"
            if [[ "$db_version" == "mysql" ]]; then
                display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/mysql/${COLOR_INFO_B})"
                prompt_variable_fixed mysql_version "MySQL version on db container" "$_mysql_version" "$_mysql_versions"
            fi
            if [[ "$db_version" == "mariadb" ]]; then
                display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO_B} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/mariadb/${COLOR_INFO_B})"
                prompt_variable_fixed mariadb_version "MySQL version on db container" "$_mariadb_version" "$_mariadb_versions"
            fi
            if [[ "$db_version" != "no" ]]; then
                prompt_variable_fixed db_import "Init example database" "$_db_import" "yes no"
            fi
        fi
        docksal_stack=""
        if [[ "$apache_version" != "no" && "$php_version" != "no" && "$db_version" != "no" ]]; then
            docksal_stack="default"
        elif [[ "$apache_version" != "no" && "$php_version" != "no" && "$db_version" == "no" ]]; then
            docksal_stack="default-nodb"
        elif [[ "$apache_version" == "no" && "$php_version" == "no" && "$db_version" == "no" && "$node_version" != "no" ]]; then
            docksal_stack="node"
        fi
        if [[ "$docksal_stack" == "" ]]; then
            _apache_version="$apache_version"
            _php_version="$php_version"
            _node_version="$node_version"
            _java_version="$java_version"
            _db_version="$db_version"
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
    db_version="no"
    docksal_stack="no"
fi

if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" && "$php_version" != "no" ]]; then
    prompt_variable_fixed symfony_config "Init example Symfony Framework config and commands?" "$_symfony_config" "yes no"
else
    symfony_config="no"
fi

if [[ "$php_version" != "no" ]]; then
    prompt_variable_fixed drupal_config "Init example Docksal Drupal config and commands?" "$_drupal_config" "yes no"
else
    drupal_config="no"
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
trap "rm -rf ${project_path}/.docksal/;exit 2" SIGINT

if [[ -d .docksal ]]; then
    display_error "Docksal config already exists!"
    confirm_or_exit "Override Docksal configuration?"
fi

if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" ]]; then
    display_info "Create basic configuration"
    fin config generate --docroot=${www_docroot} --stack=${docksal_stack}
    docksal_web_image="docksal/apache:${apache_version}"
    printf "${COLOR_DEFAULT_I}Setup web image ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}${COLOR_DEFAULT_I}\n" "$docksal_web_image"
    fin config set WEB_IMAGE="$docksal_web_image"
    if [[ "$php_version" == "5.6" || "$php_version" == "7.0" ]]; then
        docksal_cli_image="docksal/cli:2.5-php${php_version}"
    else
        docksal_cli_image="docksal/cli:2-php${php_version}"
    fi
    printf "${COLOR_DEFAULT_I}Setup cli image ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}${COLOR_DEFAULT_I}\n" "$docksal_cli_image"
    fin config set CLI_IMAGE="$docksal_cli_image"
    if [[ "$db_version" != "no" ]]; then
        if [[ "$db_version" == "mariadb" ]]; then
            docksal_db_image="docksal/mariadb:${mariadb_version}"
        elif [[ "$db_version" == "mysql" ]]; then
            docksal_db_image="docksal/mysql:${mysql_version}"
        fi
        printf "${COLOR_DEFAULT_I}Setup db image ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I}${COLOR_DEFAULT_I}\n" "$docksal_db_image"
        fin config set DB_IMAGE="${docksal_db_image}"
    fi
    if [[ "$node_version" != "no" ]]; then
        display_info "More info about ${COLOR_INFO_H}.nvmrc${COLOR_INFO_B} file on ${COLOR_INFO_H}https://github.com/creationix/nvm#nvmrc"
        echo ${node_version} >.nvmrc
    fi
    if [[ "$db_import" == "yes" || "$java_version" != "no" ]]; then
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
copy_file "gitignore" ".gitignore"
color_reset

display_info "Add custom commands"
if [[ "$application_stack" != "symfony4" && "$application_stack" != "drupal8" ]]; then
    copy_file "commands/init"
    copy_file "commands/init-site"
fi
if [[ "$node_version" != "no" ]]; then
    copy_file "commands/node/gulp" "commands/gulp"
    copy_file "commands/node/npm" "commands/npm"
fi
if [[ "$symfony_config" != "no" ]]; then
    copy_file "commands/symfony/console2" "commands/console2"
    copy_file "commands/symfony/console" "commands/console"
fi
if [[ "$db_version" != "no" ]]; then
    copy_file "commands/db/init-db" "commands/init-db"
    copy_file "commands/db/download-db" "commands/download-db"
    copy_file "commands/db/restore-db" "commands/restore-db"
    (
        printf "${COLOR_DEFAULT_I}Create ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} directory${COLOR_DEFAULT_I}\n" ".docksal/services/db/dump/"
        mkdir -p .docksal/services/db/dump/
        echo "services/db/dump/dump*.sql" >>.docksal/.gitignore
    )
fi
if [[ "$drupal_config" == "yes" ]]; then
    copy_file "commands/drupal/backup-dru-site" "commands/backup-dru-site"
    copy_file "commands/drupal/dru-admin" "commands/dru-admin"
    copy_file "commands/drupal/restore-dru-site" "commands/restore-dru-site"
    copy_file "services/cli/settings.local.php"
fi
color_reset

if [[ "$db_import" == "yes" ]]; then
    display_info "Import custom db into ${COLOR_INFO_H}db${COLOR_INFO_B} container"
    copy_file "services/db/init/init-example.sql"
    cat ${docksal_example_dir}docksal.yml/db-custom-data.yml >>.docksal/docksal.yml
    (
        printf "${COLOR_DEFAULT_I}Create ${COLOR_DEFAULT_H}%s${COLOR_DEFAULT_I} directory${COLOR_DEFAULT_I}\n" ".docksal/services/db/init/"
        mkdir -p .docksal/services/db/init/
        echo "services/db/init/init*.sql" >>.docksal/.gitignore
    )
    color_reset
fi

if [[ "$node_version" != "no" ]]; then
    display_info "Prepare Node in ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    append_file "commands/init-site-part/init-site-part-node" "commands/init-site"
    color_reset
fi

if [[ "$java_version" != "no" ]]; then
    display_info "Add ${COLOR_INFO_H}JAVA${COLOR_INFO_B} to ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/Dockerfile-with-java" "services/cli/Dockerfile"
    replace_in_file .docksal/services/cli/Dockerfile "FROM \(.*\)" "FROM $(echo "$docksal_cli_image" | sed 's/\//\\\//g')"
    cat ${docksal_example_dir}docksal.yml/cli-with-java.yml >>.docksal/docksal.yml
    color_reset
fi

if [[ "$symfony_config" != "no" ]]; then
    display_info "Add ${COLOR_INFO_H}Symfony parameters${COLOR_INFO_B} to ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    mkdir -p .docksal/services/cli/
    copy_file "services/cli/symfony/parameters.yaml" "services/cli/parameters.yaml"
    (
        symfony_secret=$(date +%s%N | shasum | base64 | head -c 32)
        replace_in_file .docksal/services/cli/parameters.yaml "secret: \(.*\)" "secret: ${symfony_secret}"
    )
    (
        symfony_base_url=$(printf ${domain_url} | sed 's:/:\\/:g')
        replace_in_file .docksal/services/cli/parameters.yaml "base_url: \(.*\)" "base_url: ${symfony_base_url}"
    )
    append_file "commands/init-site-part/init-site-part-symfony" "commands/init-site"
    copy_file "services/cli/symfony/htaccess" "../${www_docroot}/.htaccess.docksal"
    copy_file "services/cli/symfony/app_docksal.php" "../${www_docroot}/app_docksal.php"
    color_reset
fi
if [[ "$drupal_config" == "yes" ]]; then
    display_info "Add ${COLOR_INFO_H}Drupal parameters${COLOR_INFO_B} to ${COLOR_INFO_H}cli${COLOR_INFO_B} container"
    append_file "commands/init-site-part/init-site-part-drupal" "commands/init-site"
fi
display_info "Prepare readme file"
append_file "readme/docksal.md" "../README.md"
replace_in_file '../README.md' '{VIRTUAL_HOST}' "$(printf ${domain_url} | sed 's:/:\\/:g')"
if [[ "$db_version" != "no" ]]; then
    append_file "readme/db.md" "../README.md"
fi
if [[ "$node_version" != "no" ]]; then
    append_file "readme/node.md" "../README.md"
fi
if [[ "$symfony_config" != "no" ]]; then
    append_file "readme/symfony.md" "../README.md"
fi
if [[ "$drupal_config" == "yes" ]]; then
    append_file "readme/drupal.md" "../README.md"
fi

display_success "Docksal configuration is ready."
trap - SIGINT

confirm_or_exit "Initialize docker project?" "You can init project manually with ${COLOR_INFO_H}fin init${COLOR_INFO_B} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO_B} directory."
display_info "Initialize docker project (executing ${COLOR_INFO_H}fin init${COLOR_INFO_B} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO_B} directory.)"
fin init
color_reset

print_new_line
