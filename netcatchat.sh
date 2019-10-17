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
declare -r config_file_path="$(dirname $0)/config/netcatchat.sh"
if uname | grep -iq Darwin; then
    declare -r sender_hostname="$(ipconfig getifaddr en0)"
else
    declare -r sender_hostname="$(ip route get 1 | awk '{print $NF;exit}')"
fi
nc_pid=-1
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
    display_success "Sender nickname set to %s" "$sender_nickname"
    config_create 'sender_nickname' "$sender_nickname"
}
function config_load() {
    if [[ ! -f "$config_file_path" ]]; then
        display_info 'Config file create'
        mkdir -p $(dirname $config_file_path)
        touch $config_file_path
        chmod 400 $config_file_path
    else
        display_info 'Config file read'
        source $config_file_path
    fi
    if [[ -z "$sender_port" ]]; then
        app_setup_port "$NETCHAT_APP_PORT"
    fi
    if [[ -z "$sender_nickname" ]]; then
        app_setup_nickname '@'$(whoami)
    fi

    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        display_info "No recpients found - create new one"
        recipient_create
    fi
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
        display_info 'Start netcat server on %s port at %s pid' "$sender_port" "$nc_pid"
        message_from_system "${sender_nickname} in now connected to netchat from ${sender_hostname} addr on ${sender_port} port"
    else
        display_error "Sender port is not defined"
    fi
}
function netcat_kill() {
    if [[ "$nc_pid" -gt "0" ]]; then
        display_info 'Closing netcat pid %s' "$nc_pid"
        message_from_system "$sender_nickname has left the building!"
        kill ${nc_pid}
    fi
}

### RECIPIENTS ###
function recipients_list() {
    if [[ "${#chat_users[*]}" -eq "0" ]]; then
        display_error "No recipients, use :rc to define new recipient"
    else
        for recipient_name in "${!chat_users[@]}"; do
            display_info "%s %s" "$(name_to_nickname "$recipient_name")" "${chat_users[$recipient_name]}"
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
    hosts_info=($(nmap ${ip_range} -p ${NETCHAT_APP_PORT} | grep -e 'atmtcp\|report' | sed 's/atmtcp//g' | sed 's/2812\/tcp//g' | sed 's/Nmap scan report for //g'))
    local sums_total
    sums_total=${#hosts_info[@]}
    for index in $(seq 1 2 "$sums_total"); do
        recipient_ip="${hosts_info[$((index - 1))]}"
        recipient_nickname=$(echo "@$recipient_ip" | sed 's/\./_/g')
        port_state="${hosts_info[$index]}"
        if [[ "$port_state" == "open" ]]; then
            recipient_replace "${recipient_nickname}" "${recipient_ip}" "$NETCHAT_APP_PORT"
        elif [[ "$port_state" == "closed" ]]; then
            display_error "Host %s status is %s" "$recipient_ip" "$port_state"
        else
            display_info "Host %s status is %s" "$recipient_ip" "$port_state"
        fi
    done
}
function recipient_create() {
    local recipient_nickname="$1"
    local recipient_nickname_error
    if [[ -n "$recipient_nickname" ]]; then
        recipient_nickname_error=$(validate_nickname "$recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
    fi
    if [[ -z "$recipient_nickname" ]] || [[ -n "$recipient_nickname_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_error" ]]; then
                echo "$recipient_nickname_error"
            fi
            display_prompt 'recipient_nickname' '' 'Recipient name'
            recipient_nickname_error=$(validate_nickname "$recipient_nickname" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
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
        recipient_hostname_error=$(validate_hostname "$recipient_hostname")
    fi
    if [[ -z "$recipient_hostname" ]] || [[ -n "$recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$recipient_hostname_error" ]]; then
                echo "$recipient_hostname_error"
            fi
            display_prompt 'recipient_hostname' '' 'Recipient hostname'
            recipient_hostname_error=$(validate_hostname "$recipient_hostname")
            if [[ -z "$recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_port="$3"
    local recipient_port_error
    if [[ -n "$recipient_port" ]]; then
        recipient_port_error=$(validate_port "$recipient_port")
    fi
    if [[ -z "$recipient_port" ]] || [[ -n "$recipient_port_error" ]]; then
        while true; do
            if [[ -n "$recipient_port_error" ]]; then
                echo "$recipient_port_error"
            fi
            display_prompt 'recipient_port' "$NETCHAT_APP_PORT" 'Recipient port'
            recipient_port_error=$(validate_port "$recipient_port")
            if [[ -z "$recipient_port_error" ]]; then
                break
            fi
        done
    fi
    display_success "Recipient %s created on %s %s" "$recipient_nickname_new" "$recipient_hostname" "$recipient_port"
    config_create "chat_users[${recipient_name}]" "$recipient_hostname $recipient_port"
}
function recipient_update() {
    local recipient_nickname_old="$1"
    local recipient_nickname_old_error
    if [[ -n "$recipient_nickname_old" ]]; then
        recipient_nickname_old_error=$(validate_nickname "$recipient_nickname_old" "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS")
    fi
    if [[ -z "$recipient_nickname_old" ]] || [[ -n "$recipient_nickname_old_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_old_error" ]]; then
                echo "$recipient_nickname_old_error"
            fi
            display_prompt 'recipient_nickname_old' '' 'Recipient old name'
            recipient_nickname_old_error=$(validate_nickname "$recipient_nickname_old" "$NICKNAME_CHECK_MODE_ERR_IF_NOT_EXISTS")
            if [[ -z "$recipient_nickname_old_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name_old
    recipient_name_old=$(nickname_to_name "$recipient_nickname_old")
    local recipient_address_old=(${chat_users[${recipient_name_old}]})
    local recipient_hostname_old
    recipient_hostname_old="${recipient_address_old[0]}"
    local recipient_port_old
    recipient_port_old="${recipient_address_old[1]}"
    local recipient_nickname_new="$2"
    local recipient_nickname_new_error
    if [[ -n "$recipient_nickname_new" ]]; then
        recipient_nickname_new_error=$(validate_nickname "$recipient_nickname_new" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
    fi
    if [[ -z "$recipient_nickname_new" ]] || [[ -n "$recipient_nickname_new_error" ]]; then
        while true; do
            if [[ -n "$recipient_nickname_new_error" ]]; then
                echo "$recipient_nickname_new_error"
            fi
            display_prompt 'recipient_nickname_new' '' 'Recipient new name'
            recipient_nickname_new_error=$(validate_nickname "$recipient_nickname_new" "$NICKNAME_CHECK_MODE_ERR_IF_EXISTS")
            if [[ -z "$recipient_nickname_new_error" ]]; then
                break
            fi
        done
    fi
    local recipient_name_new
    recipient_name_new=$(nickname_to_name "$recipient_nickname_new")
    local recipient_hostname="$3"
    local recipient_hostname_error
    if [[ -n "$recipient_hostname" ]]; then
        recipient_hostname_error=$(validate_hostname "$recipient_hostname")
    fi
    if [[ -z "$recipient_hostname" ]] || [[ -n "$recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$recipient_hostname_error" ]]; then
                echo "$recipient_hostname_error"
            fi
            display_prompt 'recipient_hostname' "$recipient_hostname_old" 'Recipient hostname'
            recipient_hostname_error=$(validate_hostname "$recipient_hostname")
            if [[ -z "$recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_port="$4"
    local recipient_port_error
    if [[ -n "$recipient_port" ]]; then
        recipient_port_error=$(validate_port "$recipient_port")
    fi
    if [[ -z "$recipient_port" ]] || [[ -n "$recipient_port_error" ]]; then
        while true; do
            if [[ -n "$recipient_port_error" ]]; then
                echo "$recipient_port_error"
            fi
            display_prompt 'recipient_port' "$recipient_port_old" 'Recipient port'
            recipient_port_error=$(validate_port "$recipient_port")
            if [[ -z "$recipient_port_error" ]]; then
                break
            fi
        done
    fi
    display_success "Recipient %s deleted" "$recipient_nickname_old"
    config_delete "chat_users[${recipient_name_old}]"
    display_success "Recipient %s created on %s %s" "$recipient_nickname_new" "$recipient_hostname" "$recipient_port"
    config_create "chat_users[${recipient_name_new}]" "$recipient_hostname $recipient_port"
}
function recipient_replace() {
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
    local recipient_hostname="$2"
    local recipient_hostname_error
    if [[ -n "$recipient_hostname" ]]; then
        recipient_hostname_error=$(validate_hostname "$recipient_hostname")
    fi
    if [[ -z "$recipient_hostname" ]] || [[ -n "$recipient_hostname_error" ]]; then
        while true; do
            if [[ -n "$recipient_hostname_error" ]]; then
                echo "$recipient_hostname_error"
            fi
            display_prompt 'recipient_hostname' '' 'Recipient hostname'
            recipient_hostname_error=$(validate_hostname "$recipient_hostname")
            if [[ -z "$recipient_hostname_error" ]]; then
                break
            fi
        done
    fi
    local recipient_port="$3"
    local recipient_port_error
    if [[ -n "$recipient_port" ]]; then
        recipient_port_error=$(validate_port "$recipient_port")
    fi
    if [[ -z "$recipient_port" ]] || [[ -n "$recipient_port_error" ]]; then
        while true; do
            if [[ -n "$recipient_port_error" ]]; then
                echo "$recipient_port_error"
            fi
            display_prompt 'recipient_port' "$NETCHAT_APP_PORT" 'Recipient port'
            recipient_port_error=$(validate_port "$recipient_port")
            if [[ -z "$recipient_port_error" ]]; then
                break
            fi
        done
    fi
    display_success "Recipient %s created on %s %s" "$recipient_nickname" "$recipient_hostname" "$recipient_port"
    config_create "chat_users[${recipient_name}]" "$recipient_hostname $recipient_port"
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
    recipient_address=${chat_users[$recipient_name]}
    if [[ -z "$recipient_address" ]]; then
        display_error "Recipient %s is not recognized, use :rc to define new recipient or :rr to list all recipients" "$recipient_nickname"
        return 99
    else
        # send message
        display_message "${NETCHAT_APP_BELL}${message}" | nc ${recipient_address} 2>/dev/null
        local send_status=$?
        # check response
        if [[ "$send_status" == "0" ]]; then
            display_message "$message"
            return 0
        else
            display_error "Recipient %s is not connected on %s" "$recipient_nickname" "$recipient_address"
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
    display_info 'Start netcat chat at %s pid' "$$BASHPID"
    config_load
    netcat_start
    trap "echo '';netcat_kill" EXIT
}

### HELP ###
function help_screen() {
    display_info '@nickname message - write message to user'
    display_info ':sp|:port - setup app port'
    display_info ':sn|:nickname - setup Your @nickname'
    display_info ':rr|:recipients - recipients read list'
    display_info ':rc <@nickname> <ip/addr> <port> - recipient create'
    display_info ':ru <@nickname_old> <@nickname_new> <ip/addr> <port> - recipient update'
    display_info ':rd <@nickname> - recipient delete'
    display_info ':rl|:lookup - scan local network for hosts with open %s port' "$NETCHAT_APP_PORT"
    display_info ':help - help screen'
    display_info ':q|:exit|:quit|:bye - exit netchat'
}

### MAIN ###
app_init
while true; do
    case $option in
    :w)
        message_write
        ;;
    \@*)
        recipient_nickname=$(echo "$option" | awk '{print $1;}')
        message_text=$(echo "$option" | cut -d' ' -f2-)
        if [[ -n "$message_text" ]] && [[ "$message_text" != "@" ]] && [[ "$recipient_nickname" != "$message_text" ]]; then
            message_to_user "$sender_nickname" "$recipient_nickname" "$message_text"
        fi
        option=':w'
        ;;
    :sp | :port | :sp* | :port*)
        option_array=($option)
        recipient_port=${option_array[1]}
        unset option_array
        netcat_kill
        app_setup_port "$recipient_port"
        netcat_start
        option=':w'
        ;;
    :sn | :nickname | :sn* | :nickname*)
        option_array=($option)
        sender_nickname=${option_array[1]}
        unset option_array
        app_setup_nickname "$sender_nickname"
        option=':w'
        ;;
    :q | :exit | :quit | :bye)
        netcat_kill
        exit
        ;;
    :help)
        help_screen
        option=':w'
        ;;
    :rr | :recipients)
        recipients_list
        option=':w'
        ;;
    :rl | :lookup)
        hosts_scan_and_recipient_create
        option=':w'
        ;;
    :rc | :rc*)
        option_array=($option)
        recipient_nickname=${option_array[1]}
        recipient_hostname=${option_array[2]}
        recipient_port=${option_array[3]}
        unset option_array
        recipient_create "$recipient_nickname" "$recipient_hostname" "$recipient_port"
        option=':w'
        ;;
    :ru | :ru*)
        option_array=($option)
        recipient_nickname_old=${option_array[1]}
        recipient_nickname_new=${option_array[2]}
        recipient_hostname=${option_array[3]}
        recipient_port=${option_array[4]}
        unset option_array
        recipient_update "$recipient_nickname_old" "$recipient_nickname_new" "$recipient_hostname" "$recipient_port"
        option=':w'
        ;;
    :rd | :rd*)
        option_array=($option)
        recipient_nickname=${option_array[1]}
        unset option_array
        recipient_delete "$recipient_nickname"
        option=':w'
        ;;
    *)
        display_error "Command not found"
        option=':w'
        ;;
    esac
done
