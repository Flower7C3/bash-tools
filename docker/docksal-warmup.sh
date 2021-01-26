#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../_base.sh"

### CONFIG
docksal_example_dir="$(dirname "$BASH_SOURCE")/../_blueprint/docksal/"
_project_name="example_$(date "+%Y%m%d_%H%M%S")"
_application_stack="custom"
_application_stacks="custom php php-nodb node boilerplate"
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

function copy_file() {
    local src_file_name=$1
    local dst_file_name=${2:-$src_file_name}
    local source_file_path="${docksal_example_dir}${src_file_name}"
    local destination_file_path=".docksal/${dst_file_name}"
    mkdir -p "$(dirname "$destination_file_path")"
    cp "$source_file_path" "$destination_file_path"
    display_info "Copied file from ${COLOR_INFO_H}${src_file_name}${COLOR_INFO} to ${COLOR_INFO_H}${dst_file_name}${COLOR_INFO}"
}

function append_file() {
    local src_file_name=$1
    local dst_file_name=$2
    local source_file_path="${docksal_example_dir}${src_file_name}"
    local destination_file_path=".docksal/${dst_file_name}"
    cat "$source_file_path" >>"$destination_file_path"
    echo "" >>"$destination_file_path"
    display_info "Added file from ${COLOR_INFO_H}${src_file_name}${COLOR_INFO} to ${COLOR_INFO_H}${dst_file_name}${COLOR_INFO}"
}
function replace_in_file() {
    local file_path=".docksal/$1"
    local text_from="$2"
    local text_to="$3"
    if [[ ! -f $file_path ]]; then
        touch $file_path
    fi
    sed -i '' -e "s/"$text_from"/"$text_to"/g" $file_path
    display_info "Replaced in file ${COLOR_INFO_H}${file_path}${COLOR_INFO} from ${COLOR_INFO_H}${text_from}${COLOR_INFO} to ${COLOR_INFO_H}${text_to}${COLOR_INFO}"
}

### WELCOME
program_title "Docksal configuration warmup"

### VARIABLES
display_info "Configure ${COLOR_INFO_H}project${COLOR_INFO} properties"
prompt_variable_not_null project_name "Project name (lowercase alphanumeric, underscore, and hyphen)" "$_project_name" 1 "$@"
_domain_name=${project_name}
if [[ "$project_name" == "." ]]; then
    confirm_or_exit "Really want to install docksal in ${COLOR_QUESTION_B}$(pwd)${COLOR_QUESTION} directory?"
    _domain_name="$(basename $(pwd))"
fi
prompt_variable_not domain_name "Domain name (without .docksal tld)" "$_domain_name" "." 2 "$@"
domain_name="${domain_name}.docksal"
domain_url="http://${domain_name}"

display_info "Configure application containers (read more on ${COLOR_INFO_H}https://docs.docksal.io/stack/images-versions/${COLOR_INFO})"
prompt_variable_fixed application_stack "Application stack" "$_application_stack" "$_application_stacks" 3 "$@"
if [[ "$application_stack" == "node" ]]; then
    _db_version="no"
fi

if [[ "$application_stack" == "boilerplate" ]]; then
    fin project create
    exit
else
    while true; do
        apache_version="no"
        if [[ "$application_stack" == "custom" || "$application_stack" == "php" || "$application_stack" == "php-nodb" ]]; then
            display_info "Configure ${COLOR_INFO_H}web${COLOR_INFO} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/web/${COLOR_INFO})"
            prompt_variable_fixed apache_version "Apache version on web container" "$_apache_version" "$_apache_versions"
        fi
        display_info "Configure ${COLOR_INFO_H}cli${COLOR_INFO} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/cli/${COLOR_INFO})"
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
            display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/db/${COLOR_INFO})"
            prompt_variable_fixed db_version "DB version on db container" "$_db_version" "$_db_versions"
            if [[ "$db_version" == "mysql" ]]; then
                display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/mysql/${COLOR_INFO})"
                prompt_variable_fixed mysql_version "MySQL version on db container" "$_mysql_version" "$_mysql_versions"
            fi
            if [[ "$db_version" == "mariadb" ]]; then
                display_info "Configure ${COLOR_INFO_H}db${COLOR_INFO} container (read more on ${COLOR_INFO_H}https://hub.docker.com/r/docksal/mariadb/${COLOR_INFO})"
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
            display_info "Possible configurations: ${COLOR_INFO_H}Apache+PHP+MySQL${COLOR_INFO} or ${COLOR_INFO_H}Apache+PHP+Node+MySQL${COLOR_INFO} or ${COLOR_INFO_H}Apache+PHP+Node${COLOR_INFO} or ${COLOR_INFO_H}Node${COLOR_INFO}."
        else
            display_info "Docksal stack set to ${COLOR_INFO_H}$docksal_stack${COLOR_INFO}."
            break
        fi
    done
    if [[ "$php_version" != "no" ]]; then
        prompt_variable_fixed symfony_config "Init example Symfony Framework config and commands?" "$_symfony_config" "yes no"
    else
        symfony_config="no"
    fi

    if [[ "$php_version" != "no" ]]; then
        prompt_variable_fixed drupal_config "Init example Docksal Drupal config and commands?" "$_drupal_config" "yes no"
    else
        drupal_config="no"
    fi
fi

### PROGRAM
confirm_or_exit "Build Docksal configuration?"
(
    if [[ "$project_name" != "." ]]; then
        display_info "Create ${COLOR_INFO_H}$project_name${COLOR_INFO} project directory"
        mkdir -p "$project_name"
        cd "$project_name"
    else
        project_name="$(basename $(pwd))"
    fi
    project_path=$(realpath .)
    (
        trap "rm -rf \"$project_path\"/.docksal/;exit 2" SIGINT
        (
            if [[ -d .docksal ]]; then
                display_error "Docksal config already exists!"
                confirm_or_exit "Override Docksal configuration?"
            fi
        )
        (
            display_header "Create basic configuration"
            fin config generate --docroot="$www_docroot" --stack=${docksal_stack}
            (
                copy_file "gitignore" ".gitignore"
            )
            (
                display_info "Set ${COLOR_INFO_H}${domain_name}${COLOR_INFO} as hostname"
                fin config set VIRTUAL_HOST="${domain_name}"
            )
            (
                display_info "Setup web image ${COLOR_INFO_H}${docksal_web_image}${COLOR_INFO}"
                docksal_web_image="docksal/apache:${apache_version}"
                fin config set WEB_IMAGE="$docksal_web_image"
            )
            (
                display_info "Setup cli image ${COLOR_INFO_H}${docksal_cli_image}${COLOR_INFO}"
                if [[ "$php_version" == "5.6" || "$php_version" == "7.0" ]]; then
                    docksal_cli_image="docksal/cli:2.5-php${php_version}"
                else
                    docksal_cli_image="docksal/cli:2-php${php_version}"
                fi
                fin config set CLI_IMAGE="$docksal_cli_image"
            )
            (
                if [[ "$node_version" != "no" ]]; then
                    display_info "Installed ${COLOR_INFO_H}.nvmrc${COLOR_INFO} file. Read more on ${COLOR_INFO_H}https://github.com/creationix/nvm#nvmrc"
                    echo ${node_version} >.nvmrc
                fi
            )
            (
                if [[ "$db_version" != "no" ]]; then
                    display_info "Setup db image ${COLOR_INFO_H}${docksal_db_image}${COLOR_INFO}"
                    if [[ "$db_version" == "mariadb" ]]; then
                        docksal_db_image="docksal/mariadb:${mariadb_version}"
                    elif [[ "$db_version" == "mysql" ]]; then
                        docksal_db_image="docksal/mysql:${mysql_version}"
                    fi
                    fin config set DB_IMAGE="$docksal_db_image"
                fi
            )
            (
                if [[ "$db_import" == "yes" || "$java_version" != "no" ]]; then
                    echo "services:" >>.docksal/docksal.yml
                fi
            )
        )

        (
            display_header "Add custom commands"
            copy_file "commands/init"
            copy_file "commands/prepare-site"
            if [[ "$node_version" != "no" ]]; then
                copy_file "commands/node/gulp" "commands/gulp"
                copy_file "commands/node/npm" "commands/npm"
            fi
            if [[ "$symfony_config" != "no" ]]; then
                copy_file "commands/symfony/console2" "commands/console2"
                copy_file "commands/symfony/console" "commands/console"
            fi
            if [[ "$db_version" != "no" ]]; then
                copy_file "commands/db/migrate-db" "commands/migrate-db"
                copy_file "commands/db/backup-db" "commands/backup-db"
                copy_file "commands/db/restore-db" "commands/restore-db"
                (
                    display_info "Create ${COLOR_INFO_H}.docksal/services/db/dump/${COLOR_INFO} directory"
                    mkdir -p .docksal/services/db/dump/
                    echo "services/db/dump/dump*.sql" >>.docksal/.gitignore
                )
            fi
            if [[ "$drupal_config" == "yes" ]]; then
                copy_file "commands/drupal/backup-dru-site" "commands/backup-dru-site"
                copy_file "commands/drupal/dru-admin" "commands/dru-admin"
                copy_file "commands/drupal/restore-dru-site" "commands/restore-dru-site"
                copy_file "services/cli/drupal/settings.local.php" "services/cli/settings.local.php"
            fi
            if [[ "$node_version" != "no" ]]; then
                append_file "commands/prepare-site-part/prepare-site-part-node" "commands/prepare-site"
            fi
            if [[ "$symfony_config" != "no" ]]; then
                append_file "commands/prepare-site-part/prepare-site-part-symfony" "commands/prepare-site"
            fi
            if [[ "$drupal_config" == "yes" ]]; then
                append_file "commands/prepare-site-part/prepare-site-part-drupal" "commands/prepare-site"
            fi
        )
        (
            display_header "Prepare custom config"
            if [[ "$db_import" == "yes" ]]; then
                display_info "Import custom db into ${COLOR_INFO_H}db${COLOR_INFO} container"
                copy_file "services/db/init/init-example.sql"
                cat ${docksal_example_dir}docksal.yml/db-custom-data.yml >>.docksal/docksal.yml
                (
                    display_info "Create ${COLOR_INFO_H}.docksal/services/db/init/${COLOR_INFO} directory"
                    mkdir -p .docksal/services/db/init/
                    echo "services/db/init/init*.sql" >>.docksal/.gitignore
                )
            fi
            if [[ "$java_version" != "no" ]]; then
                display_info "Add ${COLOR_INFO_H}JAVA${COLOR_INFO} to ${COLOR_INFO_H}cli${COLOR_INFO} container"
                mkdir -p .docksal/services/cli/
                copy_file "services/cli/Dockerfile-with-java" "services/cli/Dockerfile"
                replace_in_file .docksal/services/cli/Dockerfile "FROM \(.*\)" "FROM $(echo "$docksal_cli_image" | sed 's/\//\\\//g')"
                cat ${docksal_example_dir}docksal.yml/cli-with-java.yml >>.docksal/docksal.yml
            fi
            if [[ "$symfony_config" != "no" ]]; then
                display_info "Add ${COLOR_INFO_H}Symfony parameters${COLOR_INFO} to ${COLOR_INFO_H}cli${COLOR_INFO} container"
                mkdir -p .docksal/services/cli/
                copy_file "services/cli/symfony/parameters.yaml" "services/cli/parameters.yaml"
                (
                    symfony_secret=$(date +%s%N | shasum | base64 | head -c 32)
                    replace_in_file .docksal/services/cli/parameters.yaml "random_secret_string" "${symfony_secret}"
                )
                (
                    symfony_base_url=$(printf ${domain_url} | sed 's:/:\\/:g')
                    replace_in_file .docksal/services/cli/parameters.yaml "example_domain_name" "${symfony_base_url}"
                )
                copy_file "services/cli/symfony/docksal.htaccess" "../${www_docroot}/.htaccess.docksal"
                copy_file "services/cli/symfony/app_docksal.php" "../${www_docroot}/app_docksal.php"
            fi
        )
        (
            display_header "Prepare readme file"
            append_file "readme/docksal-setup.md" "../README.md"
            append_file "readme/docksal-setup-init.md" "../README.md"
            append_file "readme/docksal-setup-docksal.md" "../README.md"
            append_file "readme/docksal-how-to.md" "../README.md"
            if [[ "$db_version" != "no" ]]; then
                append_file "readme/docksal-how-to-db.md" "../README.md"
            fi
            if [[ "$node_version" != "no" ]]; then
                append_file "readme/docksal-how-to-node.md" "../README.md"
            fi
            if [[ "$symfony_config" != "no" ]]; then
                append_file "readme/docksal-how-to-symfony.md" "../README.md"
            fi
            if [[ "$drupal_config" == "yes" ]]; then
                append_file "readme/docksal-how-to-drupal.md" "../README.md"
            fi
            replace_in_file '../README.md' 'PROJECT_NAME' "$(printf ${project_name} | sed 's:/:\\/:g')"
            replace_in_file '../README.md' 'VIRTUAL_HOST' "$(printf ${domain_url} | sed 's:/:\\/:g')"
        )
        display_success "Docksal configuration is ready."
        trap - SIGINT
    )
)
confirm_or_exit "Initialize docker project?" "You can init project manually with ${COLOR_INFO_H}fin init${COLOR_INFO} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO} directory."
(
    display_info "Initialize docker project (executing ${COLOR_INFO_H}fin init${COLOR_INFO} command in ${COLOR_INFO_H}${project_path}${COLOR_INFO} directory.)"
    fin init
    color_reset
)
print_new_line
