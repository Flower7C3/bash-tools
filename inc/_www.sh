###############################################################
### Web htaccess
###############################################################

function web_htaccess_symlink {
    local application_dir_path=$1
    local linkType=${2:-maintenance}
    if [[ -n "$application_dir_path" ]]; then
        if [[ "$linkType" == "maintenance" ]]; then
            printf "${color_info_b}Lock site with ${color_info_h}maintenance${color_info_b} htaccess${color_info} \n"
        else
            printf "${color_info_b}Unlock site to ${color_info_h}${linkType}${color_info_b} htaccess${color_info} \n"
        fi
        ln -sf .htaccess.${linkType} ${application_dir_path}web/.htaccess
    fi
}

###############################################################
### Symfony and assets
###############################################################

function symfony_permissions_fix {
    local symfony_cache_dir_path=$1
    local symfony_log_dir_path=$2
    if [[ -n "$symfony_cache_dir_path" ]] && [[ -n "$symfony_log_dir_path" ]]; then
        printf "${color_info_b}Fix Symfony cache and logs persmissions${color_info} \n"
        HTTPDUSER=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1)
        setfacl -R -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX ${symfony_cache_dir_path} ${symfony_log_dir_path}
        setfacl -dR -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX ${symfony_cache_dir_path} ${symfony_log_dir_path}
    else
        printf "${color_error_b}ERROR: Fix Symfony cache and logs persmission: no directories defined!${color_error} \n"
    fi
}

function composer_install {
    printf "${color_info_b}Install data from ${color_info_h}composer.lock${color_info_b} file${color_off} \n"
    composer install
}

function symfony_assets_install {
    local symfony_console=$1
    local symfony_env=$2

    if [[ -n "$symfony_console" ]]; then
        if [[ -z "$symfony_env" ]]; then
            symfony_assets_install "$symfony_console" "dev"
            symfony_assets_install "$symfony_console" "prod"
        else
            printf "${color_info_b}Install assets in ${color_info_h}${symfony_env}${color_info_b} symfony enviroment${color_off} \n"
            ${symfony_console} assets:install web --env=${symfony_env} --symlink
        fi
    else
        printf "${color_error_b}ERROR: Install Symfony assets: no console defined!${color_error} \n"
    fi
}

function symfony_assets_dump {
    local symfony_console=$1
    local symfony_env=$2

    if [[ -n "$symfony_console" ]]; then
        if [[ -z "$symfony_env" ]]; then
            symfony_assets_dump "$symfony_console" "dev"
            symfony_assets_dump "$symfony_console" "prod"
        else
            printf "${color_info_b}Dump assets in ${color_info_h}${symfony_env}${color_info_b} Symfony enviroment${color_off} \n"
            ${symfony_console} assetic:dump --env=${symfony_env}
        fi
    else
        printf "${color_error_b}ERROR: Dump Symfony assets: no console defined!${color_error} \n"
    fi
}

function assets_clear {
    local application_dir_path=$1
    if [[ -n "$application_dir_path" ]]; then
        printf "${color_info_b}Cleanup old Symfony assets${color_info} \n"
        rm -rf ${application_dir_path}web/bundles/*
        rm -rf ${application_dir_path}web/assetic/*
        rm -rf ${application_dir_path}web/fonts/*
        rm -rf ${application_dir_path}web/cache/*
        rm -rf ${application_dir_path}web/images/*
        rm -rf ${application_dir_path}web/css/*
        rm -rf ${application_dir_path}web/js/*
    else
        printf "${color_error_b}ERROR: Cleanup old Symfony assets: no application dir defined!${color_error} \n"
    fi
}

function symfony_cache_clear {
    local symfony_cache_dir_path=$1
    if [[ -n "$symfony_cache_dir_path" ]]; then
        printf "${color_info_b}Cleanup Symfony cache ${color_info} \n"
        rm -rf ${symfony_cache_dir_path}*
    else
        printf "${color_error_b}ERROR: Cleanup Symfony cache: no directories defined!${color_error} \n"
    fi
}
