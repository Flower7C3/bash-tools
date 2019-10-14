#@IgnoreInspection BashAddShebang

###############################################################
### App
###############################################################

function app_hello() {
    clear
    local name=${1:-World}
    local dirname=${2:-$(pwd)}
    program_title "Hello ${name}. Welcome at '${dirname}' directory."
}

function app_bye() {
    printf "${color_log}Bye bye. See You Later, Alligator ${color_log_b};)${color_log} \n"
    display_new_line
}

function join_by() {
    local d=$1
    shift
    printf "$1"
    shift
    printf "%s" "${@/#/$d}"
}

###############################################################
### Program info
###############################################################
function program_title() {
    local title=$1

    printf "${color_log_h}"

    printf "${box_tl}${box_h}"
    for ((c = 1; c <= ${#title}; c++)); do
        printf "${box_h}"
    done
    printf "${box_h}${box_tr}\n"

    printf "${box_v} ${title} ${box_v}\n"

    printf "${box_bl}${box_h}"
    for ((c = 1; c <= ${#title}; c++)); do
        printf "${box_h}"
    done
    printf "${box_h}${box_br}\n"

    printf "${color_off}"
}

function printfln() {
    local color_h
    color_h=$(eval echo "\$color_${1}_h")
    local color_b
    color_b=$(eval echo "\$color_${1}_b")
    shift
    local icon=$1
    shift
    local prefix
    if [[ "$1" == "TAB" ]]; then
        prefix="\t"
        shift
    fi
    local message="$1"
    shift
    printf "${prefix}${color_h}${icon}${color_b} ${message}${color_off}\n" $@
}

function display_header() {
    printfln "log" "$icon_pilcrow" "$@"
}
function display_info() {
    printfln "info" "$icon_white_right_pointing_index" "$@"
}
function display_command() {
    printfln "info" "$icon_command" "$@"
}
function display_log() {
    printfln "log" "$icon_double_angle_quotation" "$@"
}
function display_error() {
    printfln "error" "$icon_warning_sign" "$@"
}
function display_success() {
    printfln "success" "$icon_check" "$@"
}

function display_infolog() {
    local label=$1
    local value=$2
    if [[ -z "$value" ]]; then
        printf "${color_info}%s: ${color_log_b}<undefined>${color_info}\n" "$label"
    else
        printf "${color_info}%s: ${color_success_b}%s${color_info}\n" "$label" "$value"
    fi
}

function display_new_line() {
    printf "${color_off}\n"
}

function program_error() {
    display_new_line
    exit ${1:-'1'}
}

###############################################################
### I/O
###############################################################

# asks user for value
function display_prompt() {
    local prompt_mode=$1
    local variable_name=$2
    local question=$3
    local default_value=$4
    local argNo=$(expr ${5:-1} + 5)
    local args=$#
    # get value defined in argv
    if [[ ${args} -ge ${argNo} ]]; then
        variable_value=${!argNo}
        printf "${color_question_b}"
        printf "${icon_enter} ${question}"
        printf ": ${color_console}"
        if [[ "$prompt_mode" == "password" ]]; then
            printf "${color_notice}<secret>${color_console}"
        elif [[ -z "$variable_value" ]]; then
            printf "${color_notice}<undefined>${color_console}"
        else
            printf "$variable_value"
        fi
        printf "${color_off}"
        printf "\n"
    # or ask user for value
    else
        if [[ "$prompt_mode" == "password" ]] || [[ "$prompt_mode" == "repeated" ]]; then
            while true; do
                printf "${color_question_b}"
                printf "${icon_enter} ${question}"
                if [[ -n "${default_value}" ]]; then
                    printf " (default: ${color_question_h}${default_value}${color_question_b})"
                fi
                printf ": ${color_console}"
                if [[ "$prompt_mode" == "password" ]]; then
                    read -s input1
                    printf "\n"
                else
                    read -e input1
                fi
                printf "${color_off}"
                printf "${color_question_b}"
                printf "${icon_enter} ${question}"
                if [[ -n "${default_value}" ]]; then
                    printf " (default: ${color_question_h}${default_value}${color_question_b})"
                fi
                printf " (repeat): ${color_console}"
                if [[ "$prompt_mode" == "password" ]]; then
                    read -s input2
                    printf "\n"
                else
                    read -e input2
                fi
                printf "${color_off}"
                if [[ "$input1" == "$input2" ]]; then
                    input=${input1}
                    break
                else
                    display_error "Values do not match. Please retype it!"
                fi
            done
        elif [[ "$prompt_mode" == "not_null" ]]; then
            while true; do
                printf "${color_question_b}"
                printf "${icon_enter} ${question}"
                if [[ -n "${default_value}" ]]; then
                    printf " (default: ${color_question_h}${default_value}${color_question_b})"
                fi
                printf ": ${color_console}"
                read -e input
                printf "${color_off}"
                if [[ "$input" == "" && "$default_value" == "" ]]; then
                    display_error "Please enter not null value!"
                else
                    break
                fi
            done
        elif [[ "$prompt_mode" == "or_exit" ]]; then
            printf "${color_question_b}"
            printf "${icon_zigzag} ${question}"
            if [[ -n "${default_value}" ]]; then
                printf " (default: ${color_question_h}${default_value}${color_question_b})"
            fi
            printf ": ${color_console}"
            read -e input
            printf "${color_off}"
        else
            printf "${color_question_b}"
            printf "${icon_enter} ${question}"
            if [[ -n "${default_value}" ]]; then
                printf " (default: ${color_question_h}${default_value}${color_question_b})"
            fi
            printf ": ${color_console}"
            read -e input
            printf "${color_off}"
        fi
        # if user set nothing, then set default value
        variable_value=${input}
    fi
    set_variable "$variable_name" "$default_value" "$variable_value"
}

# asks user for variable value
function prompt_variable() {
    display_prompt "value" "$@"
}

function prompt_variable_twice() {
    display_prompt "repeated" "$@"
}

# asks user for variable value
function prompt_variable_or_exit() {
    display_prompt "or_exit" "$@"
}

# asks user for variable value
function prompt_variable_not_null() {
    display_prompt "not_null" "$@"
}

# asks user for variable value
function prompt_variable_not() {
    local variable_name=$1
    local question=$2
    local default_value=$3
    local prohibited_values=($4)
    shift 4
    # ask user for value from allowed list
    while true; do
        prompt_variable "$variable_name" "$question" "$default_value" "$@"
        prompt_response=$(eval echo '$'"${variable_name}")
        if test "$(echo " ${prohibited_values[*]} " | grep " ${prompt_response} ")"; then
            display_error "${color_error_b}Wrong ${color_question_b}${question}${color_error_b}. Prohibited values are: ${color_error_h}$(join_by '/' ${prohibited_values[*]})${color_error_b}!"
            set -- "${@:1:1}"
        else
            break
        fi
    done
}

# asks user for password value
function prompt_password() {
    display_prompt "password" "$@"
}

# asks user for variable value, but accept only allowed values
function prompt_variable_fixed() {
    local variable_name=$1
    local question=$2
    local default_value=$3
    local allowed_values=($4)
    local argNo=$5
    shift 4
    # ask user for value from allowed list
    while true; do
        question_string="$question"
        local args=$#
        if [[ ${args} -le ${argNo} ]]; then
            question_string="$question [$(join_by '/' ${allowed_values[*]})]"
        fi
        prompt_variable "$variable_name" "$question_string" "$default_value" "$@"
        prompt_response=$(eval echo '$'"${variable_name}")
        if test "$(echo " ${allowed_values[*]} " | grep " ${prompt_response} ")"; then
            break
        else
            display_error "${color_error_b}Wrong ${color_error_h}${question}${color_error_b} value. Allowed is one of: ${color_error_h}$(join_by '/' ${allowed_values[*]})${color_error_b}!"
            set -- "${@:0:0}"
        fi
    done
}

# asks user for variable value, but accept only allowed values
function prompt_variable_fixed_or_exit() {
    local variable_name=$1
    local question=$2
    local default_value=$3
    local allowed_values=($4)
    local argNo=$5
    shift 5
    # ask user for value from allowed list
    while true; do
        question_string="$question"
        local args=$#
        if [[ ${args} -le ${argNo} ]]; then
            question_string="$question [$(join_by '/' ${allowed_values[*]})]"
        fi
        prompt_variable_or_exit "$variable_name" "$question_string" "$default_value" "$@"
        prompt_response=$(eval echo '$'"${variable_name}")
        if test "$(echo " ${allowed_values[*]} " | grep " ${prompt_response} ")"; then
            break
        else
            display_error "${color_error_b}Wrong ${color_error_h}${question}${color_error_b} value. Allowed is one of: ${color_error_h}$(join_by '/' ${allowed_values[*]})${color_error_b}!"
            set -- "${@:0:0}"
        fi
    done
}

# set variable value
function set_variable() {
    local variable_name=$1
    local default_value=$2
    local variable_value=${3:-$default_value}
    eval "${variable_name}"'=${variable_value}'
}

# user must press y and enter, or program will end
function confirm_or_exit() {
    local question=$1
    local fallback_message=$2
    printf "\n"
    prompt_variable_fixed_or_exit run "${question}" "n" "y n" ""
    printf "\n"
    if [[ "$run" != "y" ]]; then
        if [[ "$fallback_message" != "" ]]; then
            display_info "$fallback_message"
        fi
        exit 1
    fi
    printf "\n"
}

# read variable from given ini file
function read_variable_from_config() {
    local bash_variable_name=$1
    local config_variable_name=$2
    local config_file_path=$3
    local default_value=$4
    local variable_value=$(awk -F "=" '/^'$config_variable_name'/ {print $2}' ${config_file_path} | sed 's/\"//g' | sed 's/\'"'"'//g' | sed 's/^[ ]*//;s/[ ]*$//' | sed -e 's/\'$'\t//g')
    set_variable "$bash_variable_name" "$default_value" "$variable_value"
}
