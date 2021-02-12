#@IgnoreInspection BashAddShebang

###############################################################
### App
###############################################################

function app_hello() {
    clear
    local _name=${1:-World}
    local _dirname=${2:-$(pwd)}
    program_title "Hello ${_name}. Welcome at '${_dirname}' directory."
}

function app_bye() {
    display_log "Bye bye. See You Later, Alligator ;)"
    print_new_line
}

function join_by() {
    local _delimiter=$1
    shift
    printf "$1"
    shift
    printf "%s" "${@/#/$_delimiter}"
}

###############################################################
### Program info
###############################################################
function program_title() {
    local _title=$1

    printf "${COLOR_LOG_H}"

    printf "${BOX_TL}${BOX_H}"
    for ((c = 1; c <= ${#_title}; c++)); do
        printf "${BOX_H}"
    done
    printf "${BOX_H}${BOX_TR}\n"

    printf "${BOX_V} ${_title} ${BOX_V}\n"

    printf "${BOX_BL}${BOX_H}"
    for ((c = 1; c <= ${#_title}; c++)); do
        printf "${BOX_H}"
    done
    printf "${BOX_H}${BOX_BR}\n"

    color_reset
}

declare -r DISPLAY_LINE_NO_ICON='display_line.no_icon'
declare -r DISPLAY_LINE_SILENT_BELL='display_line.silent_bell'
declare -r DISPLAY_LINE_PREPEND_NL='display_line.line_prepend_nl'
declare -r DISPLAY_LINE_PREPEND_CR='display_line.line_prepend_cr'
declare -r DISPLAY_LINE_PREPEND_TAB='display_line.line_prepend_tab'
declare -r DISPLAY_LINE_APPEND_NULL='display_line.line_append_null'
declare -r DISPLAY_LINE_APPEND_NL='display_line.line_append_nl'
function display_line() {
    local _color="$1"
    shift
    local _icon="$1 "
    shift
    local _line_prepend=""
    local _line_append="\n"
    while true; do
        case $1 in
        $DISPLAY_LINE_NO_ICON)
            _icon=""
            ;;
        $DISPLAY_LINE_SILENT_BELL)
            _line_prepend="${_line_prepend}\eg\a\r"
            ;;
        $DISPLAY_LINE_PREPEND_NL)
            _line_prepend="${_line_prepend}\n"
            ;;
        $DISPLAY_LINE_PREPEND_CR)
            _line_prepend="${_line_prepend}\r"
            ;;
        $DISPLAY_LINE_PREPEND_TAB)
            _line_prepend="${_line_prepend}\t"
            ;;
        $DISPLAY_LINE_APPEND_NL)
            _line_append="${_line_append}\n"
            ;;
        $DISPLAY_LINE_APPEND_NULL)
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
function color_reset() {
    echo -e -n "${COLOR_OFF}"
}
function display_header() {
    display_line "$COLOR_LOG" "$ICON_PARAGRAPH" "$@"
}
function display_info() {
    display_line "$COLOR_INFO" "$ICON_INFO" "$@"
}
function display_command() {
    display_line "$COLOR_INFO" "$ICON_COMMAND" "$@"
}
function display_log() {
    display_line "$COLOR_LOG" "$ICON_QUOTATION" "$@"
}
function display_error() {
    display_line "$COLOR_ERROR" "$ICON_ERROR" "$@"
}
function display_success() {
    display_line "$COLOR_SUCCESS" "$ICON_SUCCESS" "$@"
}

function display_infolog() {
    local _label=$1
    local _value=$2
    if [[ -z "$_value" ]]; then
        printf "${COLOR_INFO}%s: ${COLOR_LOG_H}<undefined>${COLOR_INFO}\n" "$_label"
    else
        printf "${COLOR_INFO}%s: ${COLOR_SUCCESS_H}%s${COLOR_INFO}\n" "$_label" "$_value"
    fi
}

function print_new_line() {
    printf "${COLOR_OFF}\n"
}

function program_error() {
    print_new_line
    exit ${1:-'1'}
}

###############################################################
### I/O
###############################################################

# asks user for value
function display_prompt() {
    local _prompt_mode=$1
    shift
    local _variable_name=$1
    shift
    local _question_text=$1
    local _question_text2=$1
    shift
    local _default_value=$1
    shift
    local _arg_no=${1:-1}
    shift
    local _args=$#
    local _prompt_text
    local _prompt_repeat
    # get value defined in argv
    if [[ ${_args} -ge ${_arg_no} ]]; then
        _variable_value=${!_arg_no}
        local _input_text
        if [[ "$_prompt_mode" == "password" ]]; then
            _input_text=$(echo -e -n "${COLOR_NOTICE}<secret>")
        elif [[ -z "$_variable_value" ]]; then
            _input_text=$(echo -e -n "${COLOR_NOTICE}<undefined>")
        else
            _input_text=$(echo -e -n "${COLOR_CONSOLE}${_variable_value}")
        fi
        display_line "$COLOR_QUESTION" "$ICON_PROMPT" "${_question_text}: ${_input_text}" "$@"
    # or ask user for value
    else
        _question_text2="${_question_text}: "
        if [[ -n "${_default_value}" ]]; then
            _question_text2="${_question_text} (default: ${COLOR_QUESTION_H}${_default_value}${COLOR_QUESTION}): "
        fi
        _prompt_text=$(display_line "$COLOR_QUESTION" "$ICON_PROMPT" "$DISPLAY_LINE_APPEND_NULL" "$_question_text2" "$@")
        _prompt_text=$(echo -e -n "${_prompt_text}${COLOR_CONSOLE}" | fold -s -w128)
        local _input_value
        if [[ "$_prompt_mode" == "password" ]] || [[ "$_prompt_mode" == "repeated" ]]; then
            local _input_value1
            local _input_value2
            local _question_repeat2="${_question_text} repeat: "
            if [[ -n "${_default_value}" ]]; then
                _question_repeat2="${_question_text} repeat (default: ${COLOR_QUESTION_H}${_default_value}${COLOR_QUESTION}): "
            fi
            _prompt_repeat=$(display_line "$COLOR_QUESTION" "$ICON_PROMPT" "$DISPLAY_LINE_APPEND_NULL" "$_question_repeat2" "$@")
            _prompt_repeat=$(echo -e -n "${_prompt_repeat}${COLOR_CONSOLE}" | fold -s -w128)
            while true; do
                if [[ "$_prompt_mode" == "password" ]]; then
                    read -r -p "${_prompt_text}" -s _input_value1
                    printf "\n"
                else
                    read -r -p "${_prompt_text}" -e _input_value1
                fi
                color_reset
                if [[ "$_prompt_mode" == "password" ]]; then
                    read -r -p "${_prompt_repeat}" -s _input_value2
                    printf "\n"
                else
                    read -r -p "${_prompt_repeat}" -e _input_value2
                fi
                color_reset
                if [[ "$_input_value1" == "$_input_value2" ]]; then
                    _input_value=${_input_value1}
                    break
                else
                    display_error "Values do not match. Please retype it!"
                fi
            done
        elif [[ "$_prompt_mode" == "not_null" ]]; then
            while true; do
                read -r -p "${_prompt_text}" -e _input_value
                color_reset
                if [[ "$_input_value" == "" && "$_default_value" == "" ]]; then
                    display_error "Please enter not null value!"
                else
                    break
                fi
            done
        else
            read -r -p "${_prompt_text}" -e _input_value
            color_reset
        fi
        # if user set nothing, then set default value
        _variable_value=${_input_value}
    fi
    set_variable "$_variable_name" "$_default_value" "$_variable_value"
}

# asks user for variable value
function prompt_variable() {
    display_prompt "value" "$@"
}

function prompt_variable_twice() {
    display_prompt "repeated" "$@"
}

# asks user for variable value
function prompt_variable_not_null() {
    display_prompt "not_null" "$@"
}

# asks user for variable value
function prompt_variable_not() {
    local _variable_name=$1
    local _question_text=$2
    local _default_value=$3
    local _prohibited_values=($4)
    shift 4
    # ask user for value from allowed list
    while true; do
        prompt_variable "$_variable_name" "$_question_text" "$_default_value" "$@"
        _prompt_response=$(eval echo '$'"${_variable_name}")
        if test "$(echo " ${_prohibited_values[*]} " | grep " ${_prompt_response} ")"; then
            display_error "Wrong ${COLOR_QUESTION_H}${_question_text}${COLOR_ERROR}. Prohibited values are: ${COLOR_ERROR_H}$(join_by '/' ${_prohibited_values[*]})${COLOR_ERROR}!"
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
    local _variable_name=$1
    local _question_text=$2
    local _question_text2
    local _default_value=$3
    local _allowed_values=($4)
    local _arg_no=$5
    local _prompt_response
    shift 4
    # ask user for value from allowed list
    while true; do
        _question_text2="$_question_text"
        local _args=$#
        if [[ ${_args} -le ${_arg_no} ]]; then
            _question_text2="$_question_text [$(join_by '/' ${_allowed_values[*]})]"
        fi
        _allowed_vals=() # short value with first letter
        for _av in "${_allowed_values[@]}"; do
            _allowed_vals+=(${_av::1})
        done
        _allowed_vals_unique=($(echo "${_allowed_vals[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
#        echo "${#_allowed_vals[@]}"
#        echo "${#_allowed_vals_unique[@]}"
        prompt_variable "$_variable_name" "$_question_text2" "$_default_value" "$@"
        _prompt_response=$(eval echo '$'"${_variable_name}")
        if [[ "${#_allowed_vals[@]}" == "${#_allowed_vals_unique[@]}" ]]; then
            if test "$(echo " ${_allowed_vals[*]} " | grep " ${_prompt_response} ")"; then
                for i in "${!_allowed_vals[@]}"; do
                    if [[ "${_prompt_response}" == "${_allowed_vals[$i]}" ]]; then
                        set_variable "$_variable_name" "${_allowed_values[$i]}"
                        break
                    fi
                done
            fi
            _prompt_response=$(eval echo '$'"${_variable_name}")
        fi
        if test "$(echo " ${_allowed_values[*]} " | grep " ${_prompt_response} ")"; then
            break
        else
            display_error "Wrong ${COLOR_ERROR_H}${_question_text}${COLOR_ERROR} value. Allowed is one of: ${COLOR_ERROR_H}$(join_by '/' ${_allowed_values[*]})${COLOR_ERROR}!"
            set -- "${@:0:0}"
        fi
    done
}

# set variable value
function set_variable() {
    local _variable_name=$1
    local _default_value=$2
    local _variable_value=${3:-$_default_value}
    eval "${_variable_name}"'=${_variable_value}'
}

# user must press y and enter, or program will end
function confirm_or_exit() {
    local _question_text=$1
    local _fallback_message=$2
    local _run
    printf "\n"
    prompt_variable_fixed _run "${_question_text}" "no" "yes no" ""
    if [[ "$_run" != "yes" ]]; then
        printf "\n"
        if [[ "$_fallback_message" != "" ]]; then
            display_info "$_fallback_message"
        fi
        exit 1
    fi
    printf "\n"
}

# read variable from given ini file
function read_variable_from_config() {
    local _bash_variable_name=$1
    local _config_variable_name=$2
    local _config_file_path=$3
    local _default_value=$4
    local _variable_value
    _variable_value=$(awk -F "=" '/^'$_config_variable_name'/ {print $2}' ${_config_file_path} | sed 's/\"//g' | sed 's/\'"'"'//g' | sed 's/^[ ]*//;s/[ ]*$//' | sed -e 's/\'$'\t//g')
    set_variable "$_bash_variable_name" "$_default_value" "$_variable_value"
}
