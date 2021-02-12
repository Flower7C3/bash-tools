#-------------------------- Helper functions --------------------------------
function copy_file() {
    local source_file_path="$1"
    local destination_file_path="$2"
    local destination_directory_path
    destination_directory_path="$(dirname "$destination_file_path")"
    mkdir -p "$destination_directory_path"
    printf "${COLOR_YELLOW}Copy ${COLOR_YELLOW_H}%s${COLOR_OFF}${COLOR_YELLOW} file to ${COLOR_YELLOW_H}%s${COLOR_OFF}${COLOR_YELLOW} directory" "$source_file_path" "$destination_directory_path"
    cp "$source_file_path" "$destination_file_path"
    printf " [OK]${COLOR_OFF}\n"
}
function download_file() {
    local url_get_path=$1
    local save_to_path=$2
    local download_status_code
    printf "${COLOR_YELLOW}Download ${COLOR_YELLOW_H}%s${COLOR_OFF}${COLOR_YELLOW} resource as ${COLOR_YELLOW_H}%s${COLOR_OFF}${COLOR_YELLOW} file" "$url_get_path" "$save_to_path"
    download_status_code=$(curl -s --insecure -w "%{http_code}" -o "$save_to_path" "$url_get_path")
    if [[ "$download_status_code" == "200" ]]; then
        printf " [OK]${COLOR_OFF}\n"
    else
        printf " [$download_status_code]${COLOR_OFF}\n"
        rm "$save_to_path"
    fi
    echo ""
}
function is_tty() {
    [[ -t 0 ]]
}
function is_docksal() {
    [[ ! "$(which fin 2>/dev/null)" == "" ]]
}
if ! is_docksal; then
    function fin() {
        bash ${PROJECT_ROOT}/.docksal/commands/$@
    }
fi

function _confirm() {
    # Skip checks if not running interactively (not a tty or not on Windows)
    if ! is_tty || [[ "$DOCKSAL_CONFIRM_YES" == "1" ]]; then return 0; fi
    while true; do
        echo -en "$1 "
        read -p "[y/n]: " answer
        case "$answer" in
        [Yy] | [Yy][Ee][Ss])
            break
            ;;
        [Nn] | [Nn][Oo])
            [[ "$2" == "--no-exit" ]] && return 1
            exit 1
            ;;
        *)
            echo 'Please answer yes or no.'
            ;;
        esac
    done
}

#-------------------------- Contents --------------------------------
# Console colors
declare -r COLOR_RED='\033[0;31m'
declare -r COLOR_RED_BG='\033[0;41m'
declare -r COLOR_YELLOW='\033[0;33m'
declare -r COLOR_YELLOW_H='\033[1;93m'
declare -r COLOR_PURPLE='\033[0;35m'
declare -r COLOR_PURPLE_B='\033[1;35m'
declare -r COLOR_PURPLE_H='\033[1;95m'
declare -r COLOR_OFF='\033[0m'

#-------------------------- Variables --------------------------------
if [[ "" == "$PROJECT_ROOT" ]]; then
    PROJECT_ROOT=$(realpath $(dirname $0)/../../)
fi
if [[ "" == "$DOCROOT" ]]; then
    if [[ -f ${PROJECT_ROOT}/.docksal/docksal.env ]]; then
        source ${PROJECT_ROOT}/.docksal/docksal.env
    fi
    if [[ -f ${PROJECT_ROOT}/.docksal/docksal-local.env ]]; then
        source ${PROJECT_ROOT}/.docksal/docksal-local.env
    fi
fi
cd $PROJECT_ROOT

timestamp=$(date +%Y%m%d_%H%I%S)
if [[ "" == "$SECRET_PART_NAME" ]]; then
    if [[ -d .git ]]; then
        SECRET_PART_NAME=$(git rev-list --max-parents=0 HEAD)
    else
        printf "${COLOR_RED}Please initialize git repository and do first commit or define ${COLOR_RED_BG}SECRET_PART_NAME${COLOR_RED} in ${COLOR_RED_BG}.docksal/docksal-local.env${COLOR_RED} file${COLOR_OFF}\n"
        exit 11
    fi
fi
secret_dir_name="secret-app-dump-${SECRET_PART_NAME}"

web_dir_path=$(realpath "${PROJECT_ROOT}/${DOCROOT}/")
