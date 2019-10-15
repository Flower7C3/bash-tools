##!/usr/bin/env bash

### VARIABLES ###
declare -r NETCHAT_SYSTEM_NICKNAME='@system'
declare -r NETCHAT_BROADCAST_NICKNAME='@all'
declare -r NETCHAT_APP_PORT='2812'
declare -A chat_users
nc_pid=-1
declare -r config_file_path=$(dirname $0)'/config/netcatchat.sh'
declare -r log_file_path=$(dirname $0)'/config/netcatchat.log'
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

### CONFIG ###
function config_setup() {
    netcat_kill
    display_prompt 'App local port'
    printf "${color_yellow}"
    read -e -r -i "$sender_port" sender_port
    printf "${color_off}"
    config_create 'sender_port' "$sender_port"
    while true; do
        display_prompt 'Your Nickname'
        printf "${color_yellow}"
        read -e -r -i "$sender_nickname" sender_nickname
        printf "${color_off}"
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
    if [[ ! -f "$log_file_path" ]]; then
        mkdir -p $(dirname $log_file_path)
        touch $log_file_path
    fi
    source $config_file_path
    cat $config_file_path | grep -v '#'
}
function config_create() {
    local variable_name="$1"
    local variable_value="$2"
    config_delete "$variable_name" "n"
    display_info "Create config variable: %s=\"${variable_value}\"" "$variable_name"
    #    printf '%s="%s"'"\n" "$variable_name" "$variable_value" >>$config_file_path
    #    eval "${variable_name}"'=${variable_value}'
}
function config_delete() {
    local variable_name="$1"
    local verbose="${2:-'y'}"
    if [[ "$verbose" == "y" ]]; then
        display_info "Delete config variable: %s" "$variable_name"
    fi
    local variable_name_escaped=$variable_name
    variable_name_escaped=${variable_name_escaped/\[/\\\[}
    variable_name_escaped=${variable_name_escaped/\]/\\\]}
    #    sed -i '' '/'$variable_name_escaped'/d' $config_file_path
    #    eval "unset ${variable_name}"
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
    printf "${color_cyan}# $text${color_off}\n" "$@"
}
function display_message() {
    local text="$1"
    shift
    printf "${color_green}$text${color_off}\n" "$@"
}
function display_error() {
    local text="$1"
    shift
    printf "${color_red}#! $text${color_off}\n" "$@"
}
function display_prompt() {
    local text="$1"
    shift
    printf "${color_yellow}#? $text: ${color_off}" "$@"
}

### NETCAT ###
function netcat_start() {
    if [[ -n "$sender_port" ]]; then
        nc -l -k ${sender_port} &
        nc_pid=$!
        display_info 'Start netcat on %s port as %s pid' "$sender_port" "$nc_pid"
        message_from_system "$sender_nickname in now connected to netchat!"
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
    for recipient_name in "${!chat_users[@]}"; do
        display_info "%s (%s)" "$(name_to_nickname "$recipient_name")" "${chat_users[$recipient_name]}"
    done
}
function recipient_add() {
    local remote_nickname="$1"
    if [[ -z "$remote_nickname" ]]; then
        while true; do
            display_prompt 'Recipient name'
            printf "${color_yellow}"
            read -e -r remote_nickname
            printf "${color_off}"
            if [[ ! $(echo "$remote_nickname" | egrep -1 "\b@[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Invalid nickname, start with @ sign"
            elif [[ "$remote_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]] || [[ "$remote_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
                display_error "Invalid nickname, %s and %s is prohibited" "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME"
            else
                break
            fi
        done
    fi
    local recipient_hostname="$2"
    if [[ -z "$recipient_hostname" ]]; then
        while true; do
            display_prompt 'Recipient hostname'
            printf "${color_yellow}"
            read -e -r recipient_hostname
            printf "${color_off}"
            if [[ ! $(echo "$recipient_hostname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Prohibited IP addr"
            else
                break
            fi
        done
    fi
    local recipient_port="$3"
    if [[ -z "$recipient_port" ]]; then
        while true; do
            display_prompt 'Recipient port'
            printf "${color_yellow}"
            read -e -r -i $NETCHAT_APP_PORT recipient_port
            printf "${color_off}"
            if [[ ! $(echo "$recipient_port" | egrep -1 "\b[0-9]+\b") ]]; then
                display_error "Prohibited port number"
            else
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$remote_nickname")
    config_create "chat_users[${recipient_name}]" "$recipient_hostname $recipient_port"
}
function recipient_delete() {
    local remote_nickname="$1"
    if [[ -z "$remote_nickname" ]]; then
        while true; do
            display_prompt 'Recipient name'
            printf "${color_yellow}"
            read -e -r remote_nickname
            printf "${color_off}"
            if [[ ! $(echo "$remote_nickname" | egrep -1 "\b@[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Invalid nickname, start with @ sign"
            elif [[ "$remote_nickname" == "$NETCHAT_SYSTEM_NICKNAME" ]] || [[ "$remote_nickname" == "$NETCHAT_BROADCAST_NICKNAME" ]]; then
                display_error "Invalid nickname, %s and %s is prohibited" "$NETCHAT_SYSTEM_NICKNAME" "$NETCHAT_BROADCAST_NICKNAME"
            else
                break
            fi
        done
    fi
    local recipient_name
    recipient_name=$(nickname_to_name "$remote_nickname")
    if [[ -z "${chat_users[$recipient_name]}" ]]; then
        display_error 'User %s not found' "$remote_nickname"
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
    printf '[%s]\t%s\t%s\t%s\n' "$datetime" "$sender_nickname" "$recipient_nickname" "$message_text" >>"$log_file_path"
}

function message_unicast() {
    local recipient_nickname="$1"
    local recipient_name
    recipient_name=$(nickname_to_name "$recipient_nickname")
    local message="$2"
    local recipient_address
    recipient_address=${chat_users[$recipient_name]}
    if [[ -z "$recipient_address" ]]; then
        display_error "User $recipient_nickname is not recognized, use :ra to define new recipient"
        return 99
    else
        # send message
        display_message "\n$message" | nc ${recipient_address}
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
function app_init() {
    config_load
    if [[ -z "$sender_port" ]] || [[ -z "$sender_nickname" ]]; then
        sender_port=$NETCHAT_APP_PORT
        sender_nickname='@'$(whoami)
        config_setup
    fi

    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        recipient_add
    fi

    netcat_start
    trap "echo '';echo '» Use :q to exit.'" SIGINT
}

### HELP ###
function help_screen() {
    display_info ':s - config setup'
    display_info ':rl - recipients list'
    display_info ':ra <name> <ip/add> <port> - recipient add'
    display_info ':rd <name> - recipient delete'
    display_info ':w - write message'
    display_info ':h - help screen'
    display_info ':q - exit'
}

### MAIN ###
app_init
while true; do
    case $option in
    :q | :exit | :quit | :bye)
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
    :ra)
        recipient_add
        option=':w'
        ;;
    :ra*)
        option_value=($option)
        remote_nickname=${option_value[1]}
        recipient_hostname=${option_value[2]}
        recipient_port=${option_value[3]}
        unset option_value
        recipient_add "$remote_nickname" "$recipient_hostname" "$recipient_port"
        option=':w'
        ;;
    :rd)
        recipient_delete
        option=':w'
        ;;
    :rd*)
        option_value=($option)
        remote_nickname=${option_value[1]}
        unset option_value
        recipient_delete "$remote_nickname"
        option=':w'
        ;;
    :w)
        printf '» '
        read -e -r option
        ;;
    *)
        if [[ $option == \@* ]]; then
            remote_nickname=$(echo "$option" | awk '{print $1;}')
            message_text=$(echo "$option" | cut -d' ' -f2-)
            if [[ -n "$message_text" ]] && [[ "$message_text" != "@" ]] && [[ "$remote_nickname" != "$message_text" ]]; then
                message_to_user "$sender_nickname" "$remote_nickname" "$message_text"
            fi
        fi
        option=':w'
        ;;
    esac
done
