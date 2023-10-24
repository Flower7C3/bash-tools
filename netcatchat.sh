#!/usr/bin/env bash

if [[ "$BASH_VERSION" == 0* ]] || [[ "$BASH_VERSION" == 1* ]] || [[ "$BASH_VERSION" == 2* ]] || [[ "$BASH_VERSION" == 3* ]]; then
    echo "Bash version is to low. Consider upgrading to bash newer than $BASH_VERSION".
    if uname | grep -iq Darwin; then
        echo "Read more on https://itnext.io/upgrading-bash-on-macos-7138bd1066ba"
    fi
    exit 9
fi

### VARIABLES ###
declare -r NETCAT_CHAT_SYSTEM_NICKNAME='@system'
declare -r NETCAT_CHAT_BROADCAST_NICKNAME='@all'
declare -r NETCAT_CHAT_APP_PORT='2812'
declare -r NICKNAME_CHECK_MODE_IGNORE='nickname_validate_mode_ignore'
declare -r NICKNAME_CHECK_MODE_ERR_IF_EXISTS='nickname_validate_mode_err_if_exists'
declare -r NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS='nickname_validate_mode_err_if_not_exists'
declare -A chat_users
declare -r config_file_path="${HOME}/.config/netcatchat/config.sh"
declare -r history_file_path="${HOME}/.config/netcatchat/history.txt"
if uname | grep -iq Darwin; then
    declare -r sender_hostname="$(ipconfig getifaddr en0)"
else
    declare -r sender_hostname="$(ip route get 1 | awk '{print $NF;exit}')"
fi
nc_pid=-1
sender_port=''
sender_nickname=''
option=''

### COLORS ###
declare -r COLOR_OFF='\033[0m'       # Text Reset
declare -r COLOR_RED='\033[0;31m'    # Red
declare -r COLOR_RED_I='\033[0;91m'  # Red
declare -r COLOR_GREEN='\033[0;32m'  # Green
declare -r COLOR_YELLOW='\033[0;33m' # Yellow
declare -r COLOR_CYAN='\033[0;36m'   # Cyan
declare -r COLOR_CYAN_I='\033[0;96m' # Cyan
declare -r COLOR_WHITE='\033[0;37m'  # White
declare -r ICON_INFO='☞'
declare -r ICON_SUCCESS='✓'
declare -r ICON_ERROR='✗'
declare -r ICON_MESSAGE='✉'
declare -r ICON_PROMPT='↳'
declare -r DISPLAY_LINE_NO_ICON='display_line.no_icon'
declare -r DISPLAY_LINE_SILENT_BELL='display_line.silent_bell'
declare -r DISPLAY_LINE_PREPEND_NL='display_line.line_prepend_nl'
declare -r DISPLAY_LINE_PREPEND_CR='display_line.line_prepend_cr'
declare -r DISPLAY_LINE_PREPEND_TAB='display_line.line_prepend_tab'
declare -r DISPLAY_LINE_APPEND_NULL='display_line.line_append_null'
declare -r DISPLAY_LINE_APPEND_NL='display_line.line_append_nl'

### DISPLAY ###
function display_line() {
    local _color=$1
    shift
    local _icon="$1 "
    shift
    local _line_prepend=""
    local _line_append="\n"
    while true; do
        case $1 in
        "$DISPLAY_LINE_NO_ICON")
            _icon=""
            ;;
        "$DISPLAY_LINE_SILENT_BELL")
            _line_prepend="\eg\a\r"
            ;;
        "$DISPLAY_LINE_PREPEND_NL")
            _line_prepend="\n"
            ;;
        "$DISPLAY_LINE_PREPEND_CR")
            _line_prepend="\r"
            ;;
        "$DISPLAY_LINE_PREPEND_TAB")
            _line_prepend="\t"
            ;;
        "$DISPLAY_LINE_APPEND_NL")
            _line_append="\n"
            ;;
        "$DISPLAY_LINE_APPEND_NULL")
            _line_append=""
            ;;
        *)
            break
            ;;
        esac
        shift
    done
    local _text_pattern="$1"
    shift
    local _text
    _text=$(printf "$_text_pattern" "$@")
    echo -e -n "${_line_prepend}${_color}${_icon}${_text}${COLOR_OFF}${_line_append}"
}
function display_info() {
    display_line "$COLOR_CYAN" "$ICON_INFO" "$@"
}
function display_message() {
    display_line "$COLOR_WHITE" "$ICON_MESSAGE" "$@"
}
function display_success() {
    display_line "$COLOR_GREEN" "$ICON_SUCCESS" "$@"
}
function display_error() {
    display_line "$COLOR_RED" "$ICON_ERROR" "$@"
}
function display_prompt() {
    local _variable_name="$1"
    local _question_text="${2:-""}"
    local _default_value="${3:-""}"
    local _variable_value="${4:-""}"
    if [[ -n "$_variable_value" ]]; then
        eval "${_variable_name}"'=${_variable_value}' 2>&1
    else
        shift
        _question_text="${_question_text}: "
        local _prompt_text
        _prompt_text=$(display_line "$COLOR_YELLOW" "$ICON_PROMPT" "$DISPLAY_LINE_APPEND_NULL" "$_question_text" "$@")
        if [[ -n "$_default_value" ]]; then
            read -e -r -p "$_prompt_text" -i "$_default_value" "$_variable_name"
        else
            read -e -r -p "$_prompt_text" "$_variable_name"
        fi
        echo -e -n "${COLOR_OFF}"
    fi
}

### CONFIG ###
function config_load() {
    display_info 'Start netcat chat at "%s" pid' "$BASHPID"
    if [[ ! -f "$config_file_path" ]]; then
        display_info 'Create config file "%s"' "$config_file_path"
        mkdir -p "$(dirname "$config_file_path")"
        touch "$config_file_path"
        chmod 400 "$config_file_path"
    else
        display_info 'Read config file "%s"' "$config_file_path"
        source $config_file_path
    fi
    history -r "$history_file_path"
    #    set -o vi
    if [[ -z "$sender_port" ]]; then
        app_setup_port
    fi
    if [[ -z "$sender_nickname" ]]; then
        sender_nickname="@$(whoami)"
        app_setup_nickname
    fi
    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        # shellcheck disable=SC2059
        display_info "$(printf "You have no recipients on contact list, type ${COLOR_CYAN_I}/create${COLOR_CYAN} to add new person")"
    fi
    while [[ "$1" != "" ]]; do
        case ${1} in
        -h | --help)
            display_info "$0 [-p <port>] [-n <@nickname>]"
            display_help_item "$(printf "sender port, default ${COLOR_CYAN_I}%s${COLOR_CYAN}" "$sender_port")" \
                '-p <port>' '--port <port>'
            display_help_item "$(printf "sender @nickname, default ${COLOR_CYAN_I}%s${COLOR_CYAN}" "$sender_nickname")" \
                '-n <@nickname>' '--nickname <@nickname>'
            display_help_item "update app" \
                '-u' '--update'
            exit 0
            ;;
        -u | --update)
            display_info "Downloading new app version"
            curl "https://raw.githubusercontent.com/Flower7C3/bash-tools/master/netcatchat.sh" >$0
            exit
            ;;
        -p | --port)
            shift
            local _sender_port_error
            _sender_port_error=$(validate_port "$1")
            if [[ -n "$_sender_port_error" ]]; then
                display_error "Invalid sender port from argv"
                exit 2
            else
                readonly sender_port=$1
            fi
            ;;
        -n | --nickname)
            shift
            local _sender_nickname_error
            _sender_nickname_error=$(validate_nickname "$1" "$NICKNAME_CHECK_MODE_IGNORE")
            if [[ -n "$_sender_nickname_error" ]]; then
                display_error "Invalid sender nickname from argv"
                exit 2
            else
                readonly sender_nickname=$1
            fi
            ;;
        esac
        shift
    done
    # shellcheck disable=SC2207
    local _has_previous_process=($(ps -a | grep "nc -l -k ${sender_port}" | grep -v 'grep' | awk '{print $1;}'))
    if [[ "${#_has_previous_process[*]}" -gt "0" ]]; then
        for _pid in "${_has_previous_process[@]}"; do
            kill "$_pid"
        done
    fi
}
function config_create() {
    local _variable_name="$1"
    local _variable_value="$2"
    local _variable_delete_error
    config_delete "$_variable_name"
    eval "${_variable_name}"'=${_variable_value}' 2>&1
    chmod 600 $config_file_path
    printf '%s="%s"'"\n" "$_variable_name" "$_variable_value" >>$config_file_path
    chmod 400 $config_file_path
}
function config_delete() {
    local _variable_name="$1"
    local _variable_name_escaped=$_variable_name
    _variable_name_escaped=${_variable_name_escaped/\[/\\\[}
    _variable_name_escaped=${_variable_name_escaped/\]/\\\]}
    eval "unset ${_variable_name}" 2>&1
    chmod 600 $config_file_path
    sed -i '' '/'$_variable_name_escaped'/d' $config_file_path
    chmod 400 $config_file_path
}

### NETCAT ###
function netcat_start() {
    if [[ -n "$sender_port" ]]; then
        nc -l -k $sender_port 2>/dev/null &
        nc_pid=$!
        display_info "$(printf "Start netcat server on ${COLOR_CYAN_I}%s${COLOR_CYAN} port with ${COLOR_CYAN_I}%s${COLOR_CYAN} pid" "$sender_port" "$nc_pid")"
        message_from_system "${sender_nickname} in now connected to netcatchat from ${sender_hostname} ${sender_port}"
    else
        display_error "Sender port is not defined"
        app_setup_port
    fi
}
function netcat_kill() {
    if [[ "$nc_pid" -gt "0" ]]; then
        message_from_system "${sender_nickname} has left the building!"
        display_info 'Closing netcat server at "%s" pid' "$nc_pid"
        kill ${nc_pid}
    fi
}

### TRAP ###
ctrlc_trap_active='n'
function ctrlc_trap_init() {
    ctrlc_trap_active='n'
    trap 'ctrlc_trap_active="y";return;' SIGINT
}
function ctrlc_trap_remove() {
    ctrlc_trap_active='n'
    trap - SIGINT
}
function ctrlc_trap_exec() {
    if [[ "$ctrlc_trap_active" == "y" ]]; then
        echo
        return 0
    fi
    return 1
}

### HISTORY ###
function history_save() {
    history -s "$option"
    history -w "$history_file_path"
}
function history_clear() {
    display_success "History removed"
    history -c
}

### NAMES ###
function name_to_nickname() {
    printf "@%s" "${1}"
}
function nickname_to_name() {
    printf "%s" "${1/@/}"
}

### VALIDATION ###
function validate_nickname() {
    local _nickname="$1"
    local _validate_exists_mode="$2"
    local _name
    _name=$(nickname_to_name "$_nickname")
    if [[ ! "$_nickname?" == @* ]]; then
        display_error 'Nickname "%s" is invalid, all nicknames starts with @ sign' "$_nickname"
        return 1
    elif [[ "$_nickname" == "$NETCAT_CHAT_SYSTEM_NICKNAME" ]] || [[ "$_nickname" == "$NETCAT_CHAT_BROADCAST_NICKNAME" ]]; then
        display_error 'Values "%s" and "%s" are reserved nicknames' "$NETCAT_CHAT_SYSTEM_NICKNAME" "$NETCAT_CHAT_BROADCAST_NICKNAME"
        return 2
    elif [[ -n "${chat_users[$_name]}" ]] && [[ "$_validate_exists_mode" == "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS" ]]; then
        display_error 'Recipient "%s" is already defined' "$_nickname"
        return 3
    elif [[ -z "${chat_users[$_name]}" ]] && [[ "$_validate_exists_mode" == "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS" ]]; then
        display_error 'Recipient "%s" is not defined' "$_nickname"
        return 4
    else
        return 0
    fi
}
function validate_hostname() {
    local _hostname=$1
    if [[ ! "$_hostname" =~ ^[A-Za-z0-9._%+-]+$ ]]; then
        display_error 'Hostname/IP address %s is invalid' "$_hostname"
        return 1
    else
        return 0
    fi
}
function validate_port() {
    local _port=$1
    if [[ ! "$_port" =~ ^[0-9]+$ ]]; then
        display_error 'Port number "%s" is invalid' "$_port"
        return 1
    elif [[ "$_port" -lt "1024" ]] || [[ "$_port" -gt "65536" ]]; then
        display_error 'Port number must be between 1024 and 65536'
        return 2
    else
        return 0
    fi
}
### SENDER ###
function app_setup_port() {
    local _new_sender_port="$1"
    local _new_sender_port_error
    while true; do
        display_prompt '_new_sender_port' 'Setup sender port number' "$NETCAT_CHAT_APP_PORT" "$_new_sender_port"
        if ctrlc_trap_exec; then
            return
        fi
        _new_sender_port_error=$(validate_port "$_new_sender_port")
        if [[ -z "$_new_sender_port_error" ]]; then
            break
        else
            echo "$_new_sender_port_error"
            _new_sender_port=''
        fi
    done
    config_create 'sender_port' "$_new_sender_port"
    display_success "Sender port set to %s" "$_new_sender_port"
}
function app_setup_nickname() {
    local _new_sender_nickname="$1"
    local _new_sender_nickname_error
    while true; do
        display_prompt '_new_sender_nickname' 'Setup sender nickname' "$sender_nickname" "$_new_sender_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_sender_nickname_error=$(validate_nickname "$_new_sender_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
        if [[ -z "$_new_sender_nickname_error" ]]; then
            break
        else
            echo "$_new_sender_nickname_error"
            _new_sender_nickname=''
        fi
    done
    local _old_sender_nickname=$sender_nickname
    config_create 'sender_nickname' "$_new_sender_nickname"
    display_success "Sender nickname set to %s" "$_new_sender_nickname"
    if [[ -n "$_old_sender_nickname" ]]; then
        message_from_system "$_old_sender_nickname is now known as $_new_sender_nickname"
    fi
}

### RECIPIENTS ###
function recipients_list() {
    local _flag=$1
    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        # shellcheck disable=SC2059
        display_error "$(printf "No recipients found, use ${COLOR_RED_I}/create${COLOR_RED} to define new recipient")"
    else
        for _recipient_name in "${!chat_users[@]}"; do
            # check status
            local recipient_nickname
            recipient_nickname=$(name_to_nickname "$_recipient_name")
            # shellcheck disable=SC2206
            local recipient_address=(${chat_users[$_recipient_name]})
            case $_flag in
            c | check)
                display_info "$DISPLAY_LINE_APPEND_NULL" "%s %s" "$recipient_nickname" "${recipient_address[*]}"
                local recipient_online_status=0
                recipient_online_status=$(ping "${recipient_address[0]}" -c 1 -t 1 2>/dev/null | grep -e 'packets' | awk '{print $4;}')
                if [[ "$recipient_online_status" -gt "0" ]]; then
                    local recipient_connection_status
                    recipient_connection_status=$(nmap "${recipient_address[0]}" -p "${recipient_address[1]}" | grep -e '/tcp' | awk '{print $2;}')
                    if [[ "$recipient_connection_status" == "open" ]]; then
                        display_success "$DISPLAY_LINE_PREPEND_CR" "%s %s is online" "$recipient_nickname" "${recipient_address[*]}"
                    else
                        display_error "$DISPLAY_LINE_PREPEND_CR" "%s %s is not connected to app" "$recipient_nickname" "${recipient_address[*]}"
                    fi
                else
                    display_error "$DISPLAY_LINE_PREPEND_CR" "%s %s is offline" "$recipient_nickname" "${recipient_address[*]}"
                fi
                ;;
            *)
                display_info "%s %s" "$recipient_nickname" "${recipient_address[*]}"
                ;;
            esac
        done
    fi
}
function hosts_scan_and_recipient_create() {
    local _nickname
    local _ip
    local _port_state
    local _ip_range
    _ip_range=$(echo "$sender_hostname" | awk -F. '{print $(1)"."$(2)"."$(3)".1-254"}')
    local _hosts_info
    _hosts_info=($(nmap ${_ip_range} -p ${NETCAT_CHAT_APP_PORT} | grep -e '/tcp\|report' | sed 's/Nmap scan report for //g'))
    local _sums_total
    _sums_total=${#_hosts_info[@]}
    for _index in $(seq 1 4 "$_sums_total"); do
        _ip="${_hosts_info[$((_index - 1))]}"
        _nickname=$(echo "@$_ip" | sed 's/\./_/g')
        _port_state="${_hosts_info[$((_index + 1))]}"
        if [[ "$_port_state" == "open" ]]; then
            recipient_update "${_nickname}" "${_ip}" "$NETCAT_CHAT_APP_PORT"
        elif [[ "$_port_state" == "closed" ]]; then
            display_error "Host %s status is %s" "$_ip" "$_port_state"
        else
            display_info "Host %s status is %s" "$_ip" "$_port_state"
        fi
    done
}
function recipient_create() {
    local _new_recipient_nickname="$1"
    local _new_recipient_nickname_error
    while true; do
        display_prompt '_new_recipient_nickname' "New recipient's nickname" '' "$_new_recipient_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_nickname_error=$(validate_nickname "$_new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
        if [[ -z "$_new_recipient_nickname_error" ]]; then
            break
        else
            echo "$_new_recipient_nickname_error"
            _new_recipient_nickname=''
        fi
    done
    local _new_recipient_name
    _new_recipient_name=$(nickname_to_name "$_new_recipient_nickname")
    local _new_recipient_hostname="$2"
    local _new_recipient_hostname_error
    while true; do
        display_prompt '_new_recipient_hostname' "New recipient's hostname/IP address" '' "$_new_recipient_hostname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_hostname_error=$(validate_hostname "$_new_recipient_hostname")
        if [[ -z "$_new_recipient_hostname_error" ]]; then
            break
        else
            echo "$_new_recipient_hostname_error"
            _new_recipient_hostname=''
        fi
    done
    local _new_recipient_port="$3"
    local _new_recipient_port_error
    while true; do
        display_prompt '_new_recipient_port' "New recipient's port number" "$NETCAT_CHAT_APP_PORT" "$_new_recipient_port"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_port_error=$(validate_port "$_new_recipient_port")
        if [[ -z "$_new_recipient_port_error" ]]; then
            break
        else
            echo "$_new_recipient_port_error"
            _new_recipient_port=''
        fi
    done
    local _new_recipient_address
    _new_recipient_address=("$_new_recipient_hostname" "$_new_recipient_port")
    for _recipient_name in "${!chat_users[@]}"; do
        local _recipient_nickname
        _recipient_nickname=$(name_to_nickname "$_recipient_name")
        if [[ "${chat_users[$_recipient_name]}" == "${_new_recipient_address[*]}" ]]; then
            display_error "Recipient's data already defined and known as %s" "$_recipient_nickname"
            return 1
        fi
    done
    config_create "chat_users[${_new_recipient_name}]" "${_new_recipient_address[*]}"
    display_success "Recipient %s created as \"%s\"" "$_new_recipient_nickname" "${_new_recipient_address[*]}"
}
function recipient_rename() {
    local old_recipient_nickname="$1"
    local old_recipient_nickname_error
    while true; do
        display_prompt 'old_recipient_nickname' "Recipient's old nickname" '' "$old_recipient_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        old_recipient_nickname_error=$(validate_nickname "$old_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS")
        if [[ -z "$old_recipient_nickname_error" ]]; then
            break
        else
            echo "$old_recipient_nickname_error"
            old_recipient_nickname=''
        fi
    done
    local old_recipient_name
    old_recipient_name=$(nickname_to_name "$old_recipient_nickname")
    local _new_recipient_nickname="$2"
    local _new_recipient_nickname_error
    while true; do
        display_prompt '_new_recipient_nickname' "Recipient's new nickname" '' "$_new_recipient_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_nickname_error=$(validate_nickname "$_new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
        if [[ -z "$_new_recipient_nickname_error" ]]; then
            break
        else
            echo "$_new_recipient_nickname_error"
            _new_recipient_nickname=''
        fi
    done
    local recipient_address
    recipient_address=(${chat_users[${old_recipient_name}]})
    local _new_recipient_name
    _new_recipient_name=$(nickname_to_name "$_new_recipient_nickname")
    config_delete "chat_users[${old_recipient_name}]" && config_create "chat_users[${_new_recipient_name}]" "${recipient_address[*]}"
    display_success "Recipient %s renamed to %s" "$old_recipient_nickname" "$_new_recipient_nickname"
}
function recipient_update() {
    local _new_recipient_nickname="$1"
    local _new_recipient_nickname_error
    while true; do
        display_prompt '_new_recipient_nickname' 'Recipient name' '' "$_new_recipient_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_nickname_error=$(validate_nickname "$_new_recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
        if [[ -z "$_new_recipient_nickname_error" ]]; then
            break
        else
            echo "$_new_recipient_nickname_error"
            _new_recipient_nickname=''
        fi
    done
    local _new_recipient_name
    _new_recipient_name=$(nickname_to_name "$_new_recipient_nickname")
    local old_recipient_address
    # shellcheck disable=SC2206
    old_recipient_address=(${chat_users[$_new_recipient_name]})
    local _new_recipient_hostname="$2"
    local _new_recipient_hostname_error
    while true; do
        display_prompt '_new_recipient_hostname' "Recipient's updated hostname/IP address" "${old_recipient_address[0]}" "$_new_recipient_hostname"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_hostname_error=$(validate_hostname "$_new_recipient_hostname")
        if [[ -z "$_new_recipient_hostname_error" ]]; then
            break
        else
            echo "$_new_recipient_hostname_error"
            _new_recipient_hostname=''
        fi
    done
    local _new_recipient_port="$3"
    local _new_recipient_port_error
    while true; do
        display_prompt '_new_recipient_port' "Recipient's updated port number" "${old_recipient_address[1]}" "$_new_recipient_port"
        if ctrlc_trap_exec; then
            return
        fi
        _new_recipient_port_error=$(validate_port "$_new_recipient_port")
        if [[ -z "$_new_recipient_port_error" ]]; then
            break
        else
            echo "$_new_recipient_port_error"
            _new_recipient_port=''
        fi
    done
    local _new_recipient_address
    _new_recipient_address=("$_new_recipient_hostname" "$_new_recipient_port")
    for _recipient_name in "${!chat_users[@]}"; do
        if [[ "${chat_users[$_recipient_name]}" == "${_new_recipient_address[*]}" ]] && [[ "$_recipient_name" != "$_new_recipient_name" ]]; then
            local _recipient_nickname=$(name_to_nickname "$_recipient_name")
            display_error "Recipient's data \"%s\" already defined and known as %s" "${_new_recipient_address[*]}" "$_recipient_nickname"
            return 1
        fi
    done
    config_create "chat_users[${_new_recipient_name}]" "${_new_recipient_address[*]}"
    display_success "Recipient %s updated as \"%s\"" "$_new_recipient_nickname" "${_new_recipient_address[*]}"
}
function recipient_delete() {
    local _recipient_nickname="$1"
    local _recipient_nickname_error
    while true; do
        display_prompt '_recipient_nickname' "Recipient's nickname to delete" '' "$_recipient_nickname"
        if ctrlc_trap_exec; then
            return
        fi
        _recipient_nickname_error=$(validate_nickname "$_recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
        if [[ -z "$_recipient_nickname_error" ]]; then
            break
        else
            echo "$_recipient_nickname_error"
            _recipient_nickname=''
        fi
    done
    local _recipient_name
    _recipient_name=$(nickname_to_name "$_recipient_nickname")
    if [[ -z "${chat_users[$_recipient_name]}" ]]; then
        display_error 'Recipient %s not found' "$_recipient_nickname"
    else
        config_delete "chat_users[${_recipient_name}]"
        display_success 'Recipient %s deleted' "$_recipient_nickname"
    fi
}

### MESSAGE ###
function message_to_user() {
    local _sender_nickname=$1
    local _recipient_nickname=$2
    local _message_text=$3
    local _datetime
    _datetime=$(date +"%Y-%m-%d %H:%M:%S")
    local _message
    local _message_status
    if [[ "$_recipient_nickname" == "$NETCAT_CHAT_BROADCAST_NICKNAME" ]]; then
        # generate message
        if [[ "$_sender_nickname" == "$NETCAT_CHAT_SYSTEM_NICKNAME" ]]; then
            _message=$(printf "[%s] %s" "$_datetime" "$_message_text")
        else
            _message=$(printf "[%s] %s broadcast: %s" "$_datetime" "$_sender_nickname" "$_message_text")
        fi
        # display loopback
        display_message "$_message"
        # send message
        for _recipient_name in "${!chat_users[@]}"; do
            _message_status=$(message_unicast "$(name_to_nickname "$_recipient_name")" "$_message")
        done
    else
        # generate message
        if [[ "$_sender_nickname" == "$NETCAT_CHAT_SYSTEM_NICKNAME" ]]; then
            _message="$(printf "[%s] %s" "$_datetime" "$_message_text")"
        else
            _message="$(printf "[%s] %s » %s: %s" "$_datetime" "$_sender_nickname" "$_recipient_nickname" "$_message_text")"
        fi
        # send message
        _message_status=$(message_unicast "$_recipient_nickname" "$_message")
        # display loopback
        printf "${_message_status}\n"
    fi
}

function message_unicast() {
    local _recipient_nickname="$1"
    local _recipient_name
    _recipient_name=$(nickname_to_name "$_recipient_nickname")
    local _message="$2"
    local _recipient_address
    # shellcheck disable=SC2206
    _recipient_address=(${chat_users[$_recipient_name]})
    # shellcheck disable=SC2128
    if [[ -z "$_recipient_address" ]]; then
        display_error "$(printf "Recipient ${COLOR_RED_I}%s${COLOR_RED} is not recognized, use ${COLOR_RED_I}/create${COLOR_RED} to define new recipient or ${COLOR_RED_I}/list${COLOR_RED} to list all recipients" "$_recipient_nickname")"
        return 99
    else
        local _recipient_hostname=${_recipient_address[0]}
        # check status
        local _recipient_online_status=0
        _recipient_online_status=$(ping "$_recipient_hostname" -c 1 -t 1 | grep -e 'packets' | awk '{print $4;}')
        if [[ "$_recipient_online_status" -gt "0" ]]; then
            # send message
            local _formatted_message
            _formatted_message="$(display_message "$DISPLAY_LINE_SILENT_BELL" "$_message")"
            _formatted_message+="$(display_line "$COLOR_YELLOW" "$ICON_PROMPT" "$DISPLAY_LINE_PREPEND_NL" "$DISPLAY_LINE_APPEND_NULL" "Chat: ")"
            # shellcheck disable=SC2086
            echo -n "${_formatted_message}" | nc -c ${_recipient_address[*]}
            local _message_send_response=$?
            # check response
            if [[ "$_message_send_response" == "0" ]]; then
                display_message "$_message"
                return 0
            else
                display_error "$(printf "Recipient ${COLOR_RED_I}%s${COLOR_RED} is not connected on %s" "$_recipient_nickname" "${_recipient_address[*]}")"
                return $_message_send_response
            fi
        else
            display_error "$(printf "Recipient %s is offline" "$_recipient_nickname")"
            return 99
        fi
    fi
}
function message_from_system() {
    local _message_text=$1
    message_to_user "$NETCAT_CHAT_SYSTEM_NICKNAME" "$NETCAT_CHAT_BROADCAST_NICKNAME" "$_message_text"
}
function option_get() {
    display_prompt 'option' 'Chat'
}
function option_reset() {
    option='/i'
}

### INIT ###
function app_init() {
    system_check
    trap "echo '';netcat_kill;" EXIT
    config_load "$@"
    netcat_start
    option_reset
}
function system_check() {
    local _required_programs=(nc ping nmap grep)
    local _is_system_ok='true'
    for _cmd in "${_required_programs[@]}"; do
        if ! hash "$_cmd" 2>/dev/null; then
            _is_system_ok='false'
            break
        fi
    done
    if [[ "$_is_system_ok" == "false" ]]; then
        display_error "Please install missing programs"
        for _cmd in "${_required_programs[@]}"; do
            if ! hash "$_cmd" 2>/dev/null; then
                display_info "$DISPLAY_LINE_PREPEND_TAB" "$DISPLAY_LINE_NO_ICON" "%s" "$_cmd"
            fi
        done
        exit 9
    fi
}

### HELP ###
function display_help_item() {
    local description="$1"
    shift
    local parameters=""
    parameters="$(printf "${COLOR_CYAN_I}%s${COLOR_CYAN}" "$1")"
    shift
    for param in "$@"; do
        parameters+=$(printf " | ${COLOR_CYAN_I}%s${COLOR_CYAN}" "$param")
    done
    display_info "$DISPLAY_LINE_NO_ICON" "$DISPLAY_LINE_PREPEND_TAB" "%s - %s" "$parameters" "$description"
}

function help_screen() {
    display_info "App commands"
    display_help_item "$(printf "write message to user, use ${COLOR_CYAN_I}%s${COLOR_CYAN} to broadcast" "@all")" \
        '@nickname message'
    display_help_item 'setup app port' \
        '/p' '/port'
    display_help_item 'setup Your @nickname' \
        '/n' '/nick'
    display_help_item 'list saved recipients' \
        '/l [c|check]' '/list [c|check]'
    display_help_item 'create new recipient' \
        '/c <@nickname> <ip/addr> <port>' '/create <@nickname> <ip/addr> <port>'
    display_help_item 'update saved recipient data' \
        '/u <@nickname> <ip/addr> <port>' '/update <@nickname> <ip/addr> <port>'
    display_help_item 'change (rename) recipient @nickname' \
        '/r <@nickname_old> <@nickname_new>' '/rename <@nickname_old> <@nickname_new>'
    display_help_item 'delete recipient' \
        '/d <@nickname>' '/delete <@nickname>'
    display_help_item 'scan local network for hosts with open '"$NETCAT_CHAT_APP_PORT"' port' \
        '/s' '/scan'
    display_help_item 'send welcome message to all users from Your recipients list' \
        '/w' '/welcome'
    display_help_item 'clear history' \
        '/x' '/clear'
    display_help_item 'help screen' \
        '/h' '/help'
    display_help_item 'exit app' \
        '/q' '/exit' '/quit' '/bye' '<ctrl>+c'
}

### MAIN ###
app_init "$@"
while true; do
    ctrlc_trap_remove
    case $option in
    /p | /port | /p\ * | /port\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_sender_port=${option_array[1]}
        unset option_array
        app_setup_port "$option_sender_port"
        netcat_kill
        netcat_start
        option_reset
        ;;
    /n | /nick | /n\ * | /nick\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_sender_nickname=${option_array[1]}
        unset option_array
        app_setup_nickname "$option_sender_nickname"
        option_reset
        ;;
    /x | /clear)
        history_clear
        option_reset
        ;;
    /q | /exit | /quit | /bye)
        break
        ;;
    /h | /help)
        help_screen
        history_save
        option_reset
        ;;
    /l | /list | /l\ * | /list\ *)
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_flag=${option_array[1]}
        unset option_array
        recipients_list "$option_flag"
        option_reset
        ;;
    /s | /scan)
        history_save
        hosts_scan_and_recipient_create
        option_reset
        ;;
    /c | /create | /c\ * | /create\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_recipient_nickname=${option_array[1]}
        option_recipient_hostname=${option_array[2]}
        option_recipient_port=${option_array[3]}
        unset option_array
        recipient_create "$option_recipient_nickname" "$option_recipient_hostname" "$option_recipient_port"
        option_reset
        ;;
    /u | /update | /u\ * | /update\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_recipient_nickname=${option_array[1]}
        option_recipient_hostname=${option_array[3]}
        option_recipient_port=${option_array[4]}
        unset option_array
        recipient_update "$option_recipient_nickname" "$option_recipient_hostname" "$option_recipient_port"
        option_reset
        ;;
    /r | /rename | /r\ * | /rename\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_old_recipient_nickname=${option_array[1]}
        option_new_recipient_nickname=${option_array[2]}
        unset option_array
        recipient_rename "$option_old_recipient_nickname" "$option_new_recipient_nickname"
        option_reset
        ;;
    /d | /delete | /d\ * | /delete\ *)
        ctrlc_trap_init
        history_save
        # shellcheck disable=SC2206
        option_array=($option)
        option_recipient_nickname=${option_array[1]}
        unset option_array
        recipient_delete "$option_recipient_nickname"
        option_reset
        ;;
    /w | /welcome)
        history_save
        message_to_user "$sender_nickname" "@all" "$(printf "Hi @all. My name is %s. You can add me to Your recipients list with ${COLOR_CYAN_I}%s${COLOR_CYAN} command" "$sender_nickname" "/create $sender_nickname $sender_hostname $sender_port")"
        option_reset
        ;;
    \@*)
        history_save
        option_recipient_nickname=$(echo "$option" | awk '{print $1;}')
        option_message_text=$(echo "$option" | cut -d' ' -f2-)
        if [[ -n "$option_message_text" ]] && [[ "$option_message_text" != "@" ]] && [[ "$option_recipient_nickname" != "$option_message_text" ]]; then
            message_to_user "$sender_nickname" "$option_recipient_nickname" "$option_message_text"
        else
            display_error "Empty message"
        fi
        option_reset
        ;;
    /i)
        option_get
        ;;
    *)
        # shellcheck disable=SC2059
        display_error "$(printf "Command not found. Use ${COLOR_RED_I}/help${COLOR_RED} to see available commands.")"
        option_reset
        ;;
    esac
done
