##!/usr/bin/env bash

function config_save() {
    local variable_name="$1"
    local variable_value="$2"
    config_delete "$variable_name"
    printf '%s="%s"'"\n" "$variable_name" "$variable_value" >>$config_file_path
    display_info "Save config: %s=\"${variable_value}\"" "$variable_name"
    eval "$variable_name"'=${variable_value}'
}
function config_delete() {
    local variable_name="$1"
    local variable_name_escaped=$variable_name
    variable_name_escaped=${variable_name_escaped/\[/\\\[}
    variable_name_escaped=${variable_name_escaped/\]/\\\]}
    sed -i '' '/'$variable_name_escaped'/d' $config_file_path
    display_info "Delete config: %s" "$variable_name"
    eval "unset $variable_name"
}

function display_newline() {
    printf "\n"
}
function display_info() {
    local message="$1"
    shift
    printf "# $message\n" "$@"
}
function display_error() {
    local message="$1"
    shift
    printf "#! $message\n" "$@"
}
function display_prompt() {
    local message="$1"
    shift
    printf "#? $message: " "$@"
}

function netcat_kill() {
    if [[ "$nc_pid" -gt "0" ]]; then
        display_info 'Closing netcat'
        kill ${nc_pid}
    fi
}

function netcat_start() {
    if [[ -n "$sender_port" ]]; then
        display_info 'Start netcat on %s port' "$sender_port"
        nc -l -k ${sender_port} &
        nc_pid=$!
    else
        display_error "Sender port is not defined"
    fi
}

function config_setup() {
    netcat_kill
    display_prompt 'App local port'
    read -e -r -i "1234" sender_port
    config_save 'sender_port' "$sender_port"
    while true; do
        display_prompt 'Nickname'
        read -e -r -i "$(whoami)" sender_nickname
        if [[ ! $(echo "$sender_nickname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
            display_error "Prohibited nickname"
        else
            break
        fi
    done
    config_save 'sender_nickname' "$sender_nickname"
    netcat_start
    display_newline
}

function config_load() {
    display_info 'CONFIG READ'
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
    display_newline
}

function recipient_add() {
    local remote_nickname="$1"
    if [[ -z "$remote_nickname" ]]; then
        while true; do
            display_prompt 'Recipient name'
            read -e -r remote_nickname
            if [[ ! $(echo "$remote_nickname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Prohibited nickname"
            else
                break
            fi
        done
    fi
    local remote_ip="$2"
    if [[ -z "$remote_ip" ]]; then
        while true; do
            display_prompt 'Recipient IP'
            read -e -r remote_ip
            if [[ ! $(echo "$remote_ip" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Prohibited IP addr"
            else
                break
            fi
        done
    fi
    local remote_port="$3"
    if [[ -z "$remote_port" ]]; then
        while true; do
            display_prompt 'Recipient port'
            read -e -r remote_port
            if [[ ! $(echo "$remote_port" | egrep -1 "\b[0-9]+\b") ]]; then
                display_error "Prohibited port number"
            else
                break
            fi
        done
    fi
    config_save "chat_users[${remote_nickname}]" "$remote_ip $remote_port"
    display_newline
}
function recipient_delete() {
    local remote_nickname="$1"
    if [[ -z "$remote_nickname" ]]; then
        while true; do
            display_prompt 'Recipient name'
            read -e -r remote_nickname
            if [[ ! $(echo "$remote_nickname" | egrep -1 "\b[A-Za-z0-9._%+-]+\b") ]]; then
                display_error "Prohibited nickname"
            else
                break
            fi
        done
    fi
    if [[ -z "${chat_users[$remote_nickname]}" ]]; then
        display_error 'User @%s not found' "$remote_nickname"
    else
        config_delete "chat_users[${remote_nickname}]"
    fi
    display_newline
}

function help_screen() {
    display_info 'HELP SCREEN'
    printf '  :cs - config setup'"\n"
    printf '  :ra <name> <ip/add> <port> - recipient add'"\n"
    printf '  :rd <name> - recipient delete'"\n"
    printf '  :w - write message'"\n"
    printf '  :h - help screen'"\n"
    printf '  :q - exit'"\n"
    display_newline
}

# init
declare -A chat_users
nc_pid=-1
config_file_path=$(dirname $0)'/config/netcatchat.sh'
log_file_path=$(dirname $0)'/config/netcatchat.log'
option=':w'

config_load
if [[ -z "$sender_port" ]] || [[ -z "$sender_nickname" ]]; then
    config_setup
fi

if [[ "${#chat_users[*]}" -eq "0" ]]; then
    recipient_add
fi

netcat_start
trap "echo '';echo '» Use :q! to exit.'" SIGINT
display_newline

# main
while true; do
    datetime=$(date +"%Y-%m-%d %H:%M:%S")
    case $option in
    :q | :exit | :quit | :bye)
        netcat_kill
        display_info 'Bye :)'
        exit
        ;;
    :h)
        help_screen
        option=':w'
        ;;
    :cs)
        config_setup
        option=':w'
        ;;
    :ra)
        recipient_add
        option=':w'
        ;;
    :ra*)
        option_value=($option)
        remote_nickname=${option_value[1]}
        remote_ip=${option_value[2]}
        remote_port=${option_value[3]}
        unset option_value
        recipient_add "$remote_nickname" "$remote_ip" "$remote_port"
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
            message=$(echo "$option" | cut -d' ' -f2-)
            echo '$message=['$message']'
            if [[ -n "$message" ]] && [[ "$message" != "@" ]] && [[ "$remote_nickname" != "$message" ]]; then
                remote_nickname=${remote_nickname/@/}
                if [[ "$remote_nickname" == "!" ]]; then
                    printf '[%s] @%s » @%s: %s\n' "$datetime" "$sender_nickname" "ALL" "$message"
                    printf '[%s]\t@%s\t@%s\t%s\n' "$datetime" "$sender_nickname" "ALL" "$message" >>"$log_file_path"
                    for remote_nickname in "${!chat_users[@]}"; do
                        remote_ip_port=${chat_users[$remote_nickname]}
                        printf '[%s] @%s » @%s: %s\n' "$datetime" "$sender_nickname" "$remote_nickname" "$message" | nc ${remote_ip_port}
                    done
                else
                    remote_ip_port=${chat_users[$remote_nickname]}
                    if [[ -z "$remote_ip_port" ]]; then
                        display_error "User @$remote_nickname is not recognized, use :ra to define new recipient"
                    else
                        printf '[%s] @%s » @%s: %s\n' "$datetime" "$sender_nickname" "$remote_nickname" "$message"
                        printf '[%s]\t@%s\t@%s\t%s\n' "$datetime" "$sender_nickname" "$remote_nickname" "$message" >>"$log_file_path"
                        printf '[%s] @%s » @%s: %s\n' "$datetime" "$sender_nickname" "$remote_nickname" "$message" | nc ${remote_ip_port}
                        if [[ "$?" != "0" ]]; then
                            display_error "User ${remote_nickname} (${remote_ip_port}) is not connected"
                        fi
                    fi
                fi
            fi
        fi
        option=':w'
        ;;
    esac
done
