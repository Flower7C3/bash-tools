#!/usr/bin/env bash

if [[ "$BASH_VERSION" != 4* ]]; then
    echo "Bash version is to low. Consider upgrading to bash 4.x".
    if uname | grep -iq Darwin; then
        echo "Read more on https://clubmate.fi/upgrade-to-bash-4-in-mac-os-x/"
    fi
    exit 9
fi

### VARIABLES ###
declare -r NETCHAT_SYSTEM_NICKNAME='@system'
declare -r NETCHAT_BROADCAST_NICKNAME='@all'
declare -r NETCHAT_APP_BELL="\eg\a"
declare -r NETCHAT_APP_PORT='2812'
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
declare -r color_off='\033[0m'       # Text Reset
declare -r color_black='\033[0;30m'  # Black
declare -r color_red='\033[0;31m'    # Red
declare -r color_green='\033[0;32m'  # Green
declare -r color_yellow='\033[0;33m' # Yellow
declare -r color_blue='\033[0;34m'   # Blue
declare -r color_purple='\033[0;35m' # Purple
declare -r color_cyan='\033[0;36m'   # Cyan
declare -r color_white='\033[0;37m'  # White
declare -r icon_info='☞'
declare -r icon_success='✓'
declare -r icon_error='✗'
declare -r icon_message='✉'
declare -r icon_prompt='↳'

### VALIDATION ###
function validate_nickname() {
    local recipient_nickname="$1"
    local validate_exists_mode="$2"
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    if [[ ! $(echo "$recipient_nickname" | egrep -1 "\b@[A-Za-z0-9._%+-]+\b") ]]; then
        display_error "Nickname %s is invalid, all nicknames starts with @ sign" "$recipient_nickname"
        return 1
    elif [[ "$recipient_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]] || [[ "$recipient_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
        display_error "Values %s and %s are reserved nicknames" "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME"
        return 2
    elif [[ -n "${chat_users[$recipient_name]}" ]] && [[ "$validate_exists_mode" == "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS" ]]; then
        display_error "Recipient %s is already defined" "$recipient_nickname"
        return 3
    elif [[ -z "${chat_users[$recipient_name]}" ]] && [[ "$validate_exists_mode" == "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS" ]]; then
        display_error "Recipient %s is not defined" "$recipient_nickname"
        return 4
    else
        return 0
    fi
}
function validate_hostname() {
    local recipient_hostname=$1
    if [[ ! $(echo "$recipient_hostname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
        display_error "Hostname/IP address %s is invalid" "$recipient_hostname"
        return 1
    else
        return 0
    fi
}
function validate_port() {
    local recipient_port=$1
    if [[ ! $(echo "$recipient_port" | egrep -1 "\b[0-9]+\b") ]]; then
        display_error "Port number %s is invalid" "$recipient_port"
        return 1
    elif [[ "$recipient_port" -lt "1024" ]] || [[ "$recipient_port" -gt "65536" ]]; then
        display_error "Port number must be between 1024 and 65536"
        return 2
    else
        return 0
    fi
}

### CONFIG ###
function app_setup_port() {
    local sender_port="$1"
    local sender_port_error
    if [[ -n "$sender_port" ]]; then
        sender_port_error=$(validate_port "$sender_port")
    fi
    if [[ -z "$sender_port" ]] || [[ -n "$sender_port_error" ]]; then
        while true; do
            if [[ -n "$sender_port_error" ]]; then
                echo "$sender_port_error"
            fi
            display_prompt 'sender_port' "$NETCHAT_APP_PORT" 'App local port'
            sender_port_error=$(validate_port "$sender_port")
            if [[ -z "$sender_port_error" ]]; then
                break
            fi
        done
    fi
    display_success "Sender port set to %s" "$sender_port"
    config_create 'sender_port' "$sender_port"
}
function app_setup_nickname() {
    local sender_nickname="$1"
    local sender_nickname_error
    if [[ -n "$sender_nickname" ]]; then
        sender_nickname_error=$(validate_nickname "$sender_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
    fi
    if [[ -z "$sender_nickname" ]] || [[ -n "$sender_nickname_error" ]]; then
        while true; do
            if [[ -n "$sender_nickname_error" ]]; then
                echo "$sender_nickname_error"
            fi
            display_prompt 'sender_nickname' '' 'Sender nickname'
            sender_nickname_error=$(validate_nickname "$sender_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
            if [[ -z "$sender_nickname_error" ]]; then
                break
            fi
        done
    fi
    local old_sender_nickname=$sender_nickname
    display_success "Sender nickname set to %s" "$sender_nickname"
    config_create 'sender_nickname' "$sender_nickname"
    message_from_system "$old_sender_nickname is now known as $sender_nickname"
}
function config_load() {
    if [[ ! -f "$config_file_path" ]]; then
        display_info 'Create config file'
        mkdir -p "$(dirname "$config_file_path")"
        touch "$config_file_path"
        chmod 400 "$config_file_path"
    else
        display_info 'Read config file'
        source $config_file_path
    fi
    history -r "$history_file_path"
    set -o vi
    if [[ -z "$sender_port" ]]; then
        app_setup_port "$NETCHAT_APP_PORT"
    fi
    local has_previous_process=($(ps -a | grep "nc -l -k ${sender_port}" | grep -v 'grep' | awk '{print $1;}'))
    if [[ "${#has_previous_process[*]}" -gt "0" ]]; then
        for pid in "${has_previous_process[@]}"; do
            kill "$pid"
        done
    fi
    if [[ -z "$sender_nickname" ]]; then
        app_setup_nickname '@'$(whoami)
    fi
    #    if [[ "${#chat_users[*]}" -eq "0" ]]; then
    #        display_info "No recpients found - create new one"
    #        recipient_create
    #    fi
}
function config_create() {
    local variable_name="$1"
    local variable_value="$2"
    config_delete "$variable_name"
    chmod 600 $config_file_path
    printf '%s="%s"'"\n" "$variable_name" "$variable_value" >>$config_file_path
    chmod 400 $config_file_path
    eval "${variable_name}"'=${variable_value}'
}
function config_delete() {
    local variable_name="$1"
    local variable_name_escaped=$variable_name
    variable_name_escaped=${variable_name_escaped/\[/\\\[}
    variable_name_escaped=${variable_name_escaped/\]/\\\]}
    chmod 600 $config_file_path
    sed -i '' '/'$variable_name_escaped'/d' $config_file_path
    chmod 400 $config_file_path
    eval "unset ${variable_name}"
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

### DISPLAY ###
function display_info() {
    local text="$1"
    shift
    printf "${color_cyan}${icon_info} $text${color_off}\n" "$@"
}
function display_message() {
    local text="$1"
    shift
    printf "${color_white}${icon_message} $text${color_off}\n" "$@"
}
function display_success() {
    local text="$1"
    shift
    printf "${color_green}${icon_success} $text${color_off}\n" "$@"
}
function display_error() {
    local text="$1"
    shift
    printf "${color_red}${icon_error} $text${color_off}\n" "$@"
}
function display_prompt() {
    local variable_name="$1"
    local default_value="$2"
    local text="$3"
    if [[ -n "$text" ]]; then
        text="${text}: "
    fi
    shift
    local prompt
    prompt=$(printf "${color_yellow}${icon_prompt} $text${color_cyan}" "$@")
    if [[ -n "$default_value" ]]; then
        read -e -r -p "$prompt" -i "$default_value" "${variable_name}"
    else
        read -e -r -p "$prompt" "${variable_name}"
    fi
    echo -e -n "${color_off}"
}

### NETCAT ###
function netcat_start() {
    if [[ -n "$sender_port" ]]; then
        nc -l -k ${sender_port} &
        nc_pid=$!
        display_info 'Start netcat server on "%s" port at "%s" pid' "$sender_port" "$nc_pid"
        message_from_system "${sender_nickname} in now connected to netchat from ${sender_hostname} ${sender_port}"
    else
        display_error "Sender port is not defined"
        app_setup_port
    fi
}
function netcat_kill() {
    if [[ "$nc_pid" -gt "0" ]]; then
        message_from_system "$sender_nickname has left the building!"
        display_info 'Closing netcat pid "%s"' "$nc_pid"
        kill ${nc_pid}
    fi
}

### RECIPIENTS ###
function recipients_list() {
    local flag=$1
    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        display_error 'No recipients found, use `/create` to define new recipient'
    else
        for recipient_name in "${!chat_users[@]}"; do
            # check satus
            local recipient_nickname
            recipient_nickname=$(name_to_nickname "$recipient_name")
            local recipient_address=(${chat_users[$recipient_name]})
            if [[ "$flag" == "check" ]]; then
                local recipient_online_status=0
                recipient_online_status=$(ping ${recipient_address[0]} -c 1 -t 1 2>/dev/null | grep -e 'packets received' | awk '{print $4;}')
                if [[ "$recipient_online_status" -gt "0" ]]; then
                    local recipient_connection_status
                    recipient_connection_status=$(nmap ${recipient_address[0]} -p ${recipient_address[1]} | grep -e '/tcp' | awk '{print $2;}')
                    if [[ "$recipient_connection_status" == "open" ]]; then
                        display_success "%s %s is online" "$recipient_nickname" "${recipient_address[*]}"
                    else
                        display_error "%s %s is not connected to app" "$recipient_nickname" "${recipient_address[*]}"
                    fi
                else
                    display_error "%s %s is offline" "$recipient_nickname" "${recipient_address[*]}"
                fi
            else
                display_info "%s %s" "$recipient_nickname" "${recipient_address[*]}"
            fi
        done
    fi
}
function hosts_scan_and_recipient_create() {
    local recipient_nickname
    local recipient_ip
    local port_state
    local ip_range
    ip_range=$(echo "$sender_hostname" | awk -F. '{print $(1)"."$(2)"."$(3)".1-254"}')
    local hosts_info
    hosts_info=($(nmap ${ip_range} -p ${NETCHAT_APP_PORT} | grep -e '/tcp\|report' | sed 's/Nmap scan report for //g'))
    local sums_total
    sums_total=${#hosts_info[@]}
    for index in $(seq 1 4 "$sums_total"); do
        recipient_ip="${hosts_info[$((index - 1))]}"
        recipient_nickname=$(echo "@$recipient_ip" | sed 's/\./_/g')
        port_state="${hosts_info[$((index + 1))]}"
        if [[ "$port_state" == "open" ]]; then
            recipient_update "${recipient_nickname}" "${recipient_ip}" "$NETCHAT_APP_PORT"
        elif [[ "$port_state" == "closed" ]]; then
            display_error "Host %s status is %s" "$recipient_ip" "$port_state"
        else
            display_info "Host %s status is %s" "$recipient_ip" "$port_state"
        fi
    done
}
function recipient_create() {
    local new_recipient_nickname="$1"
    local new_recipient_nickname_error
    if [[ -n "$new_recipient_nickname" ]]; then
        new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
    fi
    if [[ -z "$new_recipient_nickname" ]] || [[ -n "$new_recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_nickname_error" ]]; then
                echo "$new_recipient_nickname_error"
            fi
            display_prompt 'new_recipient_nickname' '' 'Recipient name'
            new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
            if [[ -z "$new_recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_name
    new_recipient_name=$(nickname_to_name "$new_recipient_nickname")
    local new_recipient_hostname="$2"
    local new_recipient_hostname_error
    if [[ -n "$new_recipient_hostname" ]]; then
        new_recipient_hostname_error=$(validate_hostname "$new_recipient_hostname")
    fi
    if [[ -z "$new_recipient_hostname" ]] || [[ -n "$new_recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_hostname_error" ]]; then
                echo "$new_recipient_hostname_error"
            fi
            display_prompt 'new_recipient_hostname' "" 'Recipient hostname'
            new_recipient_hostname_error=$(validate_hostname "$new_recipient_hostname")
            if [[ -z "$new_recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_port="$3"
    local new_recipient_port_error
    if [[ -n "$new_recipient_port" ]]; then
        new_recipient_port_error=$(validate_port "$new_recipient_port")
    fi
    if [[ -z "$new_recipient_port" ]] || [[ -n "$new_recipient_port_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_port_error" ]]; then
                echo "$new_recipient_port_error"
            fi
            display_prompt 'new_recipient_port' "$NETCHAT_APP_PORT" 'Recipient port'
            new_recipient_port_error=$(validate_port "$new_recipient_port")
            if [[ -z "$new_recipient_port_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_address
    new_recipient_address=("$new_recipient_hostname" "$new_recipient_port")
    for recipient_name in "${!chat_users[@]}"; do
        local recipient_nickname
        recipient_nickname=$(name_to_nickname "$recipient_name")
        if [[ "${chat_users[$recipient_name]}" == "${new_recipient_address[*]}" ]]; then
            display_error "Recipient already defined as @%s nickname" "$recipient_name"
            return 1
        fi
    done
    display_success "Recipient %s created on %s" "$new_recipient_nickname" "${new_recipient_address[*]}"
    config_create "chat_users[${new_recipient_name}]" "${new_recipient_address[*]}"
}
function recipient_rename() {
    local old_recipient_nickname="$1"
    local old_recipient_nickname_error
    if [[ -n "$old_recipient_nickname" ]]; then
        old_recipient_nickname_error=$(validate_nickname "$old_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS")
    fi
    if [[ -z "$old_recipient_nickname" ]] || [[ -n "$old_recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$old_recipient_nickname_error" ]]; then
                echo "$old_recipient_nickname_error"
            fi
            display_prompt 'old_recipient_nickname' '' 'Recipient old name'
            old_recipient_nickname_error=$(validate_nickname "$old_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS")
            if [[ -z "$old_recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local old_recipient_name
    old_recipient_name=$(nickname_to_name "$old_recipient_nickname")
    local new_recipient_nickname="$2"
    local new_recipient_nickname_error
    if [[ -n "$new_recipient_nickname" ]]; then
        new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
    fi
    if [[ -z "$new_recipient_nickname" ]] || [[ -n "$new_recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_nickname_error" ]]; then
                echo "$new_recipient_nickname_error"
            fi
            display_prompt 'new_recipient_nickname' '' 'Recipient new name'
            new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
            if [[ -z "$new_recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_address
    recipient_address=(${chat_users[${old_recipient_name}]})
    local new_recipient_name
    new_recipient_name=$(nickname_to_name "$new_recipient_nickname")
    display_success "Recipient %s renamed to %s" "$old_recipient_nickname" "$new_recipient_nickname"
    config_delete "chat_users[${old_recipient_name}]"
    config_create "chat_users[${new_recipient_name}]" "${recipient_address[*]}"
}
function recipient_update() {
    local new_recipient_nickname="$1"
    local new_recipient_nickname_error
    if [[ -n "$new_recipient_nickname" ]]; then
        new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
    fi
    if [[ -z "$new_recipient_nickname" ]] || [[ -n "$new_recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_nickname_error" ]]; then
                echo "$new_recipient_nickname_error"
            fi
            display_prompt 'new_recipient_nickname' '' 'Recipient name'
            new_recipient_nickname_error=$(validate_nickname "$new_recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
            if [[ -z "$new_recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_name
    new_recipient_name=$(nickname_to_name "$new_recipient_nickname")
    local old_recipient_address
    old_recipient_address=(${chat_users[$new_recipient_name]})
    local new_recipient_hostname="$2"
    local new_recipient_hostname_error
    if [[ -n "$new_recipient_hostname" ]]; then
        new_recipient_hostname_error=$(validate_hostname "$new_recipient_hostname")
    fi
    if [[ -z "$new_recipient_hostname" ]] || [[ -n "$new_recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_hostname_error" ]]; then
                echo "$new_recipient_hostname_error"
            fi
            display_prompt 'new_recipient_hostname' "${old_recipient_address[0]}" 'Recipient hostname'
            new_recipient_hostname_error=$(validate_hostname "$new_recipient_hostname")
            if [[ -z "$new_recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_port="$3"
    local new_recipient_port_error
    if [[ -n "$new_recipient_port" ]]; then
        new_recipient_port_error=$(validate_port "$new_recipient_port")
    fi
    if [[ -z "$new_recipient_port" ]] || [[ -n "$new_recipient_port_error" ]]; then
        while true; do
            if [[ -n "$new_recipient_port_error" ]]; then
                echo "$new_recipient_port_error"
            fi
            display_prompt 'new_recipient_port' "${old_recipient_address[1]}" 'Recipient port'
            new_recipient_port_error=$(validate_port "$new_recipient_port")
            if [[ -z "$new_recipient_port_error" ]]; then
                break
            fi
        done
    fi
    local new_recipient_address
    new_recipient_address=("$new_recipient_hostname" "$new_recipient_port")
    for recipient_name in "${!chat_users[@]}"; do
        if [[ "${chat_users[$recipient_name]}" == "${new_recipient_address[*]}" ]] && [[ "$recipient_name" != "$new_recipient_nickname" ]]; then
            display_error "Recipient already defined as @%s nickname" "$recipient_name"
            return 1
        fi
    done
    display_success "Recipient %s created on %s" "$new_recipient_nickname" "${new_recipient_address[*]}"
    config_create "chat_users[${new_recipient_name}]" "${new_recipient_address[*]}"
}
function recipient_delete() {
    local recipient_nickname="$1"
    local recipient_nickname_error
    if [[ -n "$recipient_nickname" ]]; then
        recipient_nickname_error=$(validate_nickname "$recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
    fi
    if [[ -z "$recipient_nickname" ]] || [[ -n "$recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_error" ]]; then
                echo "$recipient_nickname_error"
            fi
            display_prompt 'recipient_nickname' '' 'Recipient name'
            recipient_nickname_error=$(validate_nickname "$recipient_nickname" "$NICKNAME_CHECK_MODE_IGNORE")
            if [[ -z "$recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    if [[ -z "${chat_users[$recipient_name]}" ]]; then
        display_error 'Recipient %s not found' "$recipient_nickname"
    else
        display_success 'Recipient %s deleted' "$recipient_nickname"
        config_delete "chat_users[${recipient_name}]"
    fi
}

### MESSAGE ###
function message_to_user() {
    local sender_nickname=$1
    local recipient_nickname=$2
    local message_text=$3
    local datetime
    datetime=$(date +"%Y-%m-%d %H:%M:%S")
    local message
    if [[ "$recipient_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
        # generate message
        if [[ "$sender_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]]; then
            message=$(printf "[%s] %s" "$datetime" "$message_text")
        else
            message=$(printf "[%s] %s broadcast: %s" "$datetime" "$sender_nickname" "$message_text")
        fi
        # display loopback
        display_message "$message"
        # send message
        for recipient_name in "${!chat_users[@]}"; do
            message_status=$(message_unicast "$(name_to_nickname "$recipient_name")" "$message")
        done
    else
        # generate message
        if [[ "$sender_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]]; then
            message="$(printf "[%s] %s" "$datetime" "$message_text")"
        else
            message="$(printf "[%s] %s » %s: %s" "$datetime" "$sender_nickname" "$recipient_nickname" "$message_text")"
        fi
        # send message
        message_status=$(message_unicast "$recipient_nickname" "$message")
        # display loopback
        printf "${message_status}\n"
    fi
}

function message_unicast() {
    local recipient_nickname="$1"
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    local message="$2"
    local recipient_address
    recipient_address=(${chat_users[$recipient_name]})
    if [[ -z "$recipient_address" ]]; then
        display_error 'Recipient %s is not recognized, use `/create` to define new recipient or `/list` to list all recipients' "$recipient_nickname"
        return 99
    else
        local recipient_hostname=${recipient_address[0]}
        local recipient_port=${recipient_address[1]}
        # check satus
        local recipient_online_status=0
        recipient_online_status=$(ping ${recipient_hostname} -c 1 -t 1 2>/dev/null | grep -e 'packets received' | awk '{print $4;}')
        if [[ "$recipient_online_status" -gt "0" ]]; then
            # send message
            display_message "${NETCHAT_APP_BELL}${message}" | nc -w 1 ${recipient_address[*]} 2>/dev/null
            local message_send_response=$?
            # check response
            if [[ "$message_send_response" == "0" ]]; then
                display_message "$message"
                return 0
            else
                display_error "Recipient %s is not connected on %s" "$recipient_nickname" "${recipient_address[*]}"
                return $message_send_response
            fi
        else
            display_error "Recipient %s is offline" "$recipient_nickname"
            return 99
        fi
    fi
}
function message_from_system() {
    local message_text=$1
    message_to_user "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME" "$message_text"
}
function option_get() {
    display_prompt 'option' '' ''
}
function option_reset() {
    option='/i'
}

### INIT ###
function app_init() {
    trap "echo '';netcat_kill;" EXIT
    display_info 'Start netcat chat at "%s" pid' "$BASHPID"
    config_load
    netcat_start
    option_reset
}

### HELP ###
function help_screen() {
    display_info '@nickname message - write message to user'
    display_info '/p|/port - setup app port'
    display_info '/n|/nick - setup Your @nickname'
    display_info '/l|/list [check] - list saved recipients'
    display_info '/c|/create <@nickname> <ip/addr> <port> - createn new recipient'
    display_info '/u|/update <@nickname> <ip/addr> <port> - update saved recipient data'
    display_info '/r|/rename <@nickname_old> <@nickname_new> - change (rename) recipient @nickname'
    display_info '/d|/delete <@nickname> - delete recipient'
    display_info '/s|/scan - scan local network for hosts with open "%s" port' "$NETCHAT_APP_PORT"
    display_info '/x|/clear - clear history'
    display_info '/h|/help - help screen'
    display_info '/q|/exit|/quit|/bye - exit app'
}

### MAIN ###
app_init
while true; do
    case $option in
    /p | /port | /p* | /port*)
        history_save
        option_array=($option)
        recipient_port=${option_array[1]}
        unset option_array
        netcat_kill
        app_setup_port "$recipient_port"
        netcat_start
        option_reset
        ;;
    /n | /nick | /n* | /nick*)
        history_save
        option_array=($option)
        sender_nickname=${option_array[1]}
        unset option_array
        app_setup_nickname "$sender_nickname"
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
    /l | /list | "/l check" | "/list check")
        history_save
        option_array=($option)
        flag=${option_array[1]}
        unset option_array
        recipients_list "$flag"
        option_reset
        ;;
    /s | /scan)
        history_save
        hosts_scan_and_recipient_create
        option_reset
        ;;
    /c | /create | /c* | /create*)
        history_save
        option_array=($option)
        new_recipient_nickname=${option_array[1]}
        new_recipient_hostname=${option_array[2]}
        new_recipient_port=${option_array[3]}
        unset option_array
        recipient_create "$new_recipient_nickname" "$new_recipient_hostname" "$new_recipient_port"
        option_reset
        ;;
    /u | /update | /u* | /update*)
        history_save
        option_array=($option)
        recipient_nickname=${option_array[1]}
        recipient_hostname=${option_array[3]}
        recipient_port=${option_array[4]}
        unset option_array
        recipient_update "$recipient_nickname" "$recipient_hostname" "$recipient_port"
        option_reset
        ;;
    /r | /rename | /r* | /rename*)
        history_save
        option_array=($option)
        old_recipient_nickname=${option_array[1]}
        new_recipient_nickname=${option_array[2]}
        unset option_array
        recipient_rename "$old_recipient_nickname" "$new_recipient_nickname"
        option_reset
        ;;
    /d | /delete | /d* | /delete*)
        history_save
        option_array=($option)
        recipient_nickname=${option_array[1]}
        unset option_array
        recipient_delete "$recipient_nickname"
        option_reset
        ;;
    \@*)
        history_save
        recipient_nickname=$(echo "$option" | awk '{print $1;}')
        message_text=$(echo "$option" | cut -d' ' -f2-)
        if [[ -n "$message_text" ]] && [[ "$message_text" != "@" ]] && [[ "$recipient_nickname" != "$message_text" ]]; then
            message_to_user "$sender_nickname" "$recipient_nickname" "$message_text"
        else
            display_error "Empty message"
        fi
        option_reset
        ;;
    *)
        option_get
        ;;
    esac
done
