###############################################################
### Web htaccess
###############################################################

function web_htaccess_symlink {
    local applicationDir=$1
    local linkType=${2:-maintenance}
    if [[ -n "$applicationDir" ]]; then
        if [[ "$linkType" == "maintenance" ]]; then
            printf "${InfoB}Lock site with ${InfoBI}maintenance${InfoB} htaccess${Info} \n"
        else
            printf "${InfoB}Unlock site to ${InfoBI}${linkType}${InfoB} htaccess${Info} \n"
        fi
        ln -sf .htaccess.${linkType} ${applicationDir}web/.htaccess
    fi
}

###############################################################
### Symfony and assets
###############################################################

function symfony_permissions_fix {
    local symfonyCache=$1
    local symfonyLogs=$2
    if [[ -n "$symfonyCache" ]] && [[ -n "$symfonyLogs" ]]; then
        printf "${InfoB}Fix Symfony cache and logs persmissions${Info} \n"
        HTTPDUSER=$(ps axo user,comm | grep -E '[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx' | grep -v root | head -1 | cut -d\  -f1)
        setfacl -R -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX ${symfonyCache} ${symfonyLogs}
        setfacl -dR -m u:"$HTTPDUSER":rwX -m u:$(whoami):rwX ${symfonyCache} ${symfonyLogs}
    else
        printf "${ErrorB}ERROR: Fix Symfony cache and logs persmission: no directories defined!${Error} \n"
    fi
}

function composer_install {
    printf "${InfoB}Install data from ${InfoBI}composer.lock${InfoB} file${Color_Off} \n"
    composer install
}

function symfony_assets_install {
    local symfonyConsole=$1
    local symfonyEnv=$2

    if [[ -n "$symfonyConsole" ]]; then
        if [[ -z "$symfonyEnv" ]]; then
            assets_install "$symfonyConsole" "dev"
            assets_install "$symfonyConsole" "prod"
        else
            printf "${InfoB}Install assets in ${InfoBI}${symfonyEnv}${InfoB} symfony enviroment${Color_Off} \n"
            ${symfonyConsole} assets:install web --env=${symfonyEnv} --symlink
        fi
    else
        printf "${ErrorB}ERROR: Install Symfony assets: no console defined!${Error} \n"
    fi
}

function symfony_assets_dump {
    local symfonyConsole=$1
    local symfonyEnv=$2

    if [[ -n "$symfonyConsole" ]]; then
        if [[ -z "$symfonyEnv" ]]; then
            assets_dump "$symfonyConsole" "dev"
            assets_dump "$symfonyConsole" "prod"
        else
            printf "${InfoB}Dump assets in ${InfoBI}${symfonyEnv}${InfoB} Symfony enviroment${Color_Off} \n"
            ${symfonyConsole} assetic:dump --env=${symfonyEnv}
        fi
    else
        printf "${ErrorB}ERROR: Dump Symfony assets: no console defined!${Error} \n"
    fi
}

function assets_clear {
    local applicationDir=$1
    if [[ -n "$applicationDir" ]]; then
        printf "${InfoB}Cleanup old Symfony assets${Info} \n"
        rm -rf ${applicationDir}web/bundles/*
        rm -rf ${applicationDir}web/assetic/*
        rm -rf ${applicationDir}web/fonts/*
        rm -rf ${applicationDir}web/cache/*
        rm -rf ${applicationDir}web/images/*
        rm -rf ${applicationDir}web/css/*
        rm -rf ${applicationDir}web/js/*
    else
        printf "${ErrorB}ERROR: Cleanup old Symfony assets: no application dir defined!${Error} \n"
    fi
}

function symfony_cache_clear {
    local symfonyCache=$1
    if [[ -n "$symfonyCache" ]]; then
        printf "${InfoB}Cleanup Symfony cache ${Info} \n"
        rm -rf ${symfonyCache}*
    else
        printf "${ErrorB}ERROR: Cleanup Symfony cache: no directories defined!${Error} \n"
    fi
}
