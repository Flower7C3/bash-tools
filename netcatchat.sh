#!/usr/bin/env bash

### VARIABLES ###
declare -r NETCHAT_SYSTEM_NICKNAME='@system'
declare -r NETCHAT_BROADCAST_NICKNAME='@all'
declare -r NETCHAT_APP_PORT='2812'
declare -A chat_users
nc_pid=-1
declare -r config_file_path=$(dirname $0)'/config/netcatchat.sh'
#declare -r log_file_path=$(dirname $0)'/config/netcatchat.log'
if uname | grep -iq Darwin; then
    declare -r sender_hostname=$(ipconfig getifaddr en0)
else
    declare -r sender_hostname=$(ip route get 1 | awk '{print $NF;exit}')
fi
sender_port=''
sender_nickname=''
option=':w'

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

### CONFIG ###
function config_setup() {
    netcat_kill
    display_prompt 'sender_port' "$sender_port" 'App local port'
    config_create 'sender_port' "$sender_port"
    while true; do
        display_prompt 'sender_nickname' "$sender_nickname" 'Your Nickname'
        if [[ ! $(echo "$sender_nickname" | egrep -1 "\b@[A-Za-z0-9._%+-]+\b") ]]; then
            display_error "Invalid nickname, start with @ sign"
        elif [[ "$sender_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]] || [[ "$sender_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
            display_error "Invalid nickname, %s and %s is prohibited" "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME"
        else
            break
        fi
    done
    config_create 'sender_nickname' "$sender_nickname"
    netcat_start
}
function config_load() {
    display_info 'Config read'
    if [[ ! -f "$config_file_path" ]]; then
        mkdir -p $(dirname $config_file_path)
        touch $config_file_path
    fi
#    if [[ ! -f "$log_file_path" ]]; then
#        mkdir -p $(dirname $log_file_path)
#        touch $log_file_path
#    fi
    source $config_file_path
}
function config_create() {
    local variable_name="$1"
    local variable_value="$2"
    config_delete "$variable_name" "n"
    display_success "Config variable saved: %s=\"${variable_value}\"" "$variable_name"
    printf '%s="%s"'"\n" "$variable_name" "$variable_value" >>$config_file_path
    eval "${variable_name}"'=${variable_value}'
}
function config_delete() {
    local variable_name="$1"
    local verbose="${2:-y}"
    if [[ "$verbose" == "y" ]]; then
        display_success "Config variable deleted: %s" "$variable_name"
    fi
    local variable_name_escaped=$variable_name
    variable_name_escaped=${variable_name_escaped/\[/\\\[}
    variable_name_escaped=${variable_name_escaped/\]/\\\]}
    sed -i '' '/'$variable_name_escaped'/d' $config_file_path
    eval "unset ${variable_name}"
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
    shift
    printf "${color_yellow}${icon_prompt} $text: ${color_off}" "$@"
    printf "${color_yellow}"
    if [[ -n "$default_value" ]]; then
        read -e -r -i "$default_value" "${variable_name}"
    else
        read -e -r "${variable_name}"
    fi
    printf "${color_off}"
}

### NETCAT ###
function netcat_start() {
    if [[ -n "$sender_port" ]]; then
        nc -l -k ${sender_port} &
        nc_pid=$!
        display_info 'Start netcat on %s port as %s pid' "$sender_port" "$nc_pid"
        message_from_system "${sender_nickname} in now connected to netchat from ${sender_hostname} addr on ${sender_port} port"
    else
        display_error "Sender port is not defined"
    fi
}
function netcat_kill() {
    if [[ "$nc_pid" -gt "0" ]]; then
        message_from_system "$sender_nickname has left the building!"
        display_info 'Closing netcat pid %s' "$nc_pid"
        kill ${nc_pid}
    fi
}

### RECIPIENTS ###
function recipients_list() {
    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        display_error "No recipients, use :rc to define new recipient"
    else
        for recipient_name in "${!chat_users[@]}"; do
            display_info "%s (%s)" "$(name_to_nickname "$recipient_name")" "${chat_users[$recipient_name]}"
        done
    fi
}
function check_nickname() {
    local recipient_nickname="$1"
    local must_be_unique="${2:-n}"
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    if [[ ! $(echo "$recipient_nickname" | egrep -1 "\b@[A-Za-z0-9._%+-]+\b") ]]; then
        display_error "Nickname %s is invalid, all nicknames starts with @ sign" "$recipient_nickname"
        return 1
    elif [[ "$recipient_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]] || [[ "$recipient_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
        display_error "Values %s and %s are reserved nicknames" "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME"
        return 2
    elif [[ -n "${chat_users[$recipient_name]}" ]] && [[ "$must_be_unique" == "y" ]]; then
        display_error "User %s is already defined" "$recipient_nickname"
        return 3
    else
        return 0
    fi
}
function check_hostname() {
    local recipient_hostname=$1
    if [[ ! $(echo "$recipient_hostname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
        display_error "Hostname/IP address %s is invalid" "$recipient_hostname"
        return 1
    else
        return 0
    fi
}
function check_port() {
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
function recipient_create() {
    local recipient_nickname="$1"
    local recipient_nickname_error
    if [[ -n "$recipient_nickname" ]]; then
        recipient_nickname_error=$(check_nickname "$recipient_nickname" "y")
    fi
    if [[ -z "$recipient_nickname" ]] || [[ -n "$recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_error" ]]; then
                echo "$recipient_nickname_error"
            fi
            display_prompt 'recipient_nickname' '' 'Recipient name'
            recipient_nickname_error=$(check_nickname "$recipient_nickname" "y")
            if [[ -z "$recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    local recipient_hostname="$2"
    local recipient_hostname_error
    if [[ -n "$recipient_hostname" ]]; then
        recipient_hostname_error=$(check_hostname "$recipient_hostname")
    fi
    if [[ -z "$recipient_hostname" ]] || [[ -n "$recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$recipient_hostname_error" ]]; then
                echo "$recipient_hostname_error"
            fi
            display_prompt 'recipient_hostname' '' 'Recipient hostname'
            recipient_hostname_error=$(check_hostname "$recipient_hostname")
            if [[ -z "$recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_port="$3"
    local recipient_port_error
    if [[ -n "$recipient_port" ]]; then
        recipient_port_error=$(check_port "$recipient_port")
    fi
    if [[ -z "$recipient_port" ]] || [[ -n "$recipient_port_error" ]]; then
        while true; do
            if [[ -n "$recipient_port_error" ]]; then
                echo "$recipient_port_error"
            fi
            display_prompt 'recipient_port' "$NETCHAT_APP_PORT" 'Recipient port'
            recipient_port_error=$(check_port "$recipient_port")
            if [[ -z "$recipient_port_error" ]]; then
                break
            fi
        done
    fi
    config_create "chat_users[${recipient_name}]" "$recipient_hostname $recipient_port"
}
function recipient_update() {
    local recipient_nickname="$1"
    local recipient_nickname_error
    if [[ -n "$recipient_nickname" ]]; then
        recipient_nickname_error=$(check_nickname "$recipient_nickname")
    fi
    if [[ -z "$recipient_nickname" ]] || [[ -n "$recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_error" ]]; then
                echo "$recipient_nickname_error"
            fi
            display_prompt 'recipient_nickname' '' 'Recipient name'
            recipient_nickname_error=$(check_nickname "$recipient_nickname")
            if [[ -z "$recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    local recipient_hostname="$2"
    local recipient_hostname_error
    if [[ -n "$recipient_hostname" ]]; then
        recipient_hostname_error=$(check_hostname "$recipient_hostname")
    fi
    if [[ -z "$recipient_hostname" ]] || [[ -n "$recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$recipient_hostname_error" ]]; then
                echo "$recipient_hostname_error"
            fi
            display_prompt 'recipient_hostname' '' 'Recipient hostname'
            recipient_hostname_error=$(check_hostname "$recipient_hostname")
            if [[ -z "$recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_port="$3"
    local recipient_port_error
    if [[ -n "$recipient_port" ]]; then
        recipient_port_error=$(check_port "$recipient_port")
    fi
    if [[ -z "$recipient_port" ]] || [[ -n "$recipient_port_error" ]]; then
        while true; do
            if [[ -n "$recipient_port_error" ]]; then
                echo "$recipient_port_error"
            fi
            display_prompt 'recipient_port' "$NETCHAT_APP_PORT" 'Recipient port'
            recipient_port_error=$(check_port "$recipient_port")
            if [[ -z "$recipient_port_error" ]]; then
                break
            fi
        done
    fi
    config_create "chat_users[${recipient_name}]" "$recipient_hostname $recipient_port"
}
function recipient_delete() {
    local recipient_nickname="$1"
    local recipient_nickname_error
    if [[ -n "$recipient_nickname" ]]; then
        recipient_nickname_error=$(check_nickname "$recipient_nickname")
    fi
    if [[ -z "$recipient_nickname" ]] || [[ -n "$recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_error" ]]; then
                echo "$recipient_nickname_error"
            fi
            display_prompt 'recipient_nickname' '' 'Recipient name'
            recipient_nickname_error=$(check_nickname "$recipient_nickname")
            if [[ -z "$recipient_nickname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    if [[ -z "${chat_users[$recipient_name]}" ]]; then
        display_error 'User %s not found' "$recipient_nickname"
    else
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
    # save logfile
#    printf '[%s]\t%s\t%s\t%s\n' "$datetime" "$sender_nickname" "$recipient_nickname" "$message_text" >>"$log_file_path"
}

function message_unicast() {
    local recipient_nickname="$1"
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    local message="$2"
    local recipient_address
    recipient_address=${chat_users[$recipient_name]}
    if [[ -z "$recipient_address" ]]; then
        display_error "User $recipient_nickname is not recognized, use :rc to define new recipient or :rl to list all recipients"
        return 99
    else
        # send message
        display_message "$message" | nc ${recipient_address} 2>/dev/null
        local send_status=$?
        # check response
        if [[ "$send_status" == "0" ]]; then
            display_message "$message"
            return 0
        else
            display_error "User %s (%s) is not connected" "$recipient_nickname" "$recipient_address"
            return $send_status
        fi
    fi
}
function message_from_system() {
    local message_text=$1
    message_to_user "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME" "$message_text"
}
function message_write() {
    printf "${color_white}${icon_prompt} "
    read -e -r option
    printf "${color_off}"
}

### INIT ###
function app_init() {
    config_load
    if [[ -z "$sender_port" ]] || [[ -z "$sender_nickname" ]]; then
        sender_port=$NETCHAT_APP_PORT
        sender_nickname='@'$(whoami)
        config_setup
    fi

    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        recipient_create
    fi

    netcat_start
    trap "echo '';netcat_kill" EXIT
}

### HELP ###
function help_screen() {
    display_info '@nickname message - write message to user'
    display_info ':s - setup app port and Your @nickname'
    display_info ':rl - recipients list'
    display_info ':rc <@nickname> <ip/addr> <port> - recipient create'
    display_info ':ru <@nickname> <ip/addr> <port> - recipient update'
    display_info ':rd <@nickname> - recipient delete'
    display_info ':h - help screen'
    display_info ':q|:exit|:quit|:bye - exit netchat'
}

### MAIN ###
app_init
while true; do
    case $option in
    :q | :exit | :quit | :bye )
        netcat_kill
        exit
        ;;
    :h)
        help_screen
        option=':w'
        ;;
    :s)
        config_setup
        option=':w'
        ;;
    :rl)
        recipients_list
        option=':w'
        ;;
    :rc)
        recipient_create
        option=':w'
        ;;
    :rc*)
        option_array=($option)
        recipient_nickname=${option_array[1]}
        recipient_hostname=${option_array[2]}
        recipient_port=${option_array[3]}
        unset option_array
        recipient_create "$recipient_nickname" "$recipient_hostname" "$recipient_port"
        option=':w'
        ;;
    :ru)
        recipient_update
        option=':w'
        ;;
    :ru*)
        option_array=($option)
        recipient_nickname=${option_array[1]}
        recipient_hostname=${option_array[2]}
        recipient_port=${option_array[3]}
        unset option_array
        recipient_update "$recipient_nickname" "$recipient_hostname" "$recipient_port"
        option=':w'
        ;;
    :rd)
        recipient_delete
        option=':w'
        ;;
    :rd*)
        option_array=($option)
        recipient_nickname=${option_array[1]}
        unset option_array
        recipient_delete "$recipient_nickname"
        option=':w'
        ;;
    *)
        if [[ $option == \@* ]]; then
            recipient_nickname=$(echo "$option" | awk '{print $1;}')
            message_text=$(echo "$option" | cut -d' ' -f2-)
            if [[ -n "$message_text" ]] && [[ "$message_text" != "@" ]] && [[ "$recipient_nickname" != "$message_text" ]]; then
                message_to_user "$sender_nickname" "$recipient_nickname" "$message_text"
            fi
            option=':w'
        else
            message_write
        fi
        ;;
    esac
done
