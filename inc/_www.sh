###############################################################
### Web htaccess
###############################################################

function web_htaccess_symlink() {
    local application_dir_path=$1
    local linkType=${2:-maintenance}
    if [[ -n "$application_dir_path" ]]; then
        if [[ "$linkType" == "maintenance" ]]; then
            printf "${COLOR_INFO_B}Lock site with ${COLOR_INFO_H}maintenance${COLOR_INFO_B} htaccess${COLOR_INFO} \n"
        else
            printf "${COLOR_INFO_B}Unlock site to ${COLOR_INFO_H}${linkType}${COLOR_INFO_B} htaccess${COLOR_INFO} \n"
        fi
        ln -sf .htaccess.${linkType} ${application_dir_path}web/.htaccess
    fi
}

###############################################################
### Symfony and assets
###############################################################

function symfony_permissions_fix() {
    local symfony_cache_dir_path=$1
    local symfony_log_dir_path=$2
    if [[ -n "$symfony_cache_dir_path" ]] && [[ -n "$symfony_log_dir_path" ]]; then
        printf "${COLOR_INFO_B}Fix Symfony cache and logs persmissions${COLOR_INFO} \n"
        local _httpduser
        _httpduser=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1)
        setfacl -R -m u:"$_httpduser":rwX -m u:$(whoami):rwX ${symfony_cache_dir_path} ${symfony_log_dir_path}
        setfacl -dR -m u:"$_httpduser":rwX -m u:$(whoami):rwX ${symfony_cache_dir_path} ${symfony_log_dir_path}
    else
        printf "${COLOR_ERROR_B}ERROR: Fix Symfony cache and logs persmission: no directories defined!${COLOR_ERROR} \n"
    fi
}

function composer_install() {
    local composer_command=${1:-"composer"}
    local interactive=${2:-"y"}
    printf "${COLOR_INFO_B}Install data from ${COLOR_INFO_H}composer.lock${COLOR_INFO_B} file${COLOR_OFF} \n"
    if [[ "$interactive" == "n" ]]; then
        ${composer_command} install --no-interaction
    else
        ${composer_command} install
    fi
}

function symfony_assets_install() {
    local symfony_console=$1
    local symfony_env=$2

    if [[ -n "$symfony_console" ]]; then
        if [[ -z "$symfony_env" ]]; then
            symfony_assets_install "$symfony_console" "dev"
            symfony_assets_install "$symfony_console" "prod"
        else
            printf "${COLOR_INFO_B}Install assets in ${COLOR_INFO_H}${symfony_env}${COLOR_INFO_B} symfony enviroment${COLOR_OFF} \n"
            ${symfony_console} assets:install web --env=${symfony_env} --symlink
        fi
    else
        printf "${COLOR_ERROR_B}ERROR: Install Symfony assets: no console defined!${COLOR_ERROR} \n"
    fi
}

function symfony_assets_dump() {
    local symfony_console=$1
    local symfony_env=$2

    if [[ -n "$symfony_console" ]]; then
        if [[ -z "$symfony_env" ]]; then
            symfony_assets_dump "$symfony_console" "dev"
            symfony_assets_dump "$symfony_console" "prod"
        else
            printf "${COLOR_INFO_B}Dump assets in ${COLOR_INFO_H}${symfony_env}${COLOR_INFO_B} Symfony enviroment${COLOR_OFF} \n"
            ${symfony_console} assetic:dump --env=${symfony_env}
        fi
    else
        printf "${COLOR_ERROR_B}ERROR: Dump Symfony assets: no console defined!${COLOR_ERROR} \n"
    fi
}

function assets_clear() {
    local application_dir_path=$1
    if [[ -n "$application_dir_path" ]]; then
        printf "${COLOR_INFO_B}Cleanup old Symfony assets${COLOR_INFO} \n"
        rm -rf "$application_dir_path""web/bundles/"*
        rm -rf "$application_dir_path""web/assetic/"*
        rm -rf "$application_dir_path""web/fonts/"*
        rm -rf "$application_dir_path""web/cache/"*
        rm -rf "$application_dir_path""web/images/"*
        rm -rf "$application_dir_path""web/css/"*
        rm -rf "$application_dir_path""web/js/"*
    else
        printf "${COLOR_ERROR_B}ERROR: Cleanup old Symfony assets: no application dir defined!${COLOR_ERROR} \n"
    fi
}

function symfony_cache_clear() {
    local symfony_cache_dir_path=$1
    if [[ -n "$symfony_cache_dir_path" ]]; then
        printf "${COLOR_INFO_B}Cleanup Symfony cache ${COLOR_INFO} \n"
        rm -rf "$symfony_cache_dir_path"*
    else
        printf "${COLOR_ERROR_B}ERROR: Cleanup Symfony cache: no directories defined!${COLOR_ERROR} \n"
    fi
}
