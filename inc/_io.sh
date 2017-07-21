###############################################################
### App
###############################################################

function app_hello {
    clear
    local name=${1:-World}
    local dirname=${2:-`pwd`}
    program_title "Hello ${name}. Welcome at '${dirname}' directory."
}

function app_bye {
    printf "${color_log}Bye bye. See You Later, Alligator ${color_log_b};)${color_log} \n"
    program_end
}

###############################################################
### Program info
###############################################################
function program_title {
	local title=$1

	printf "${color_log_h}"

	printf "${box_tl}${box_h}"
	for (( c=1; c<=${#title} ; c++ ))
	do
	   printf "${box_h}"
	done
	printf "${box_h}${box_tr}\n"

	printf "${box_v} ${title} ${box_v}\n"

	printf "${box_bl}${box_h}"
	for (( c=1; c<=${#title} ; c++ ))
	do
	   printf "${box_h}"
	done
	printf "${box_h}${box_br}\n"
	
	printf "${color_off}"
}

function printfln {
	local message=$1
	printf "${message}\n"
}

function display_info {
    local message=$1
    printf "${color_info_b}(I) ${message}\n"
}

function display_error {
    local message=$1
    printf "${color_error_b}(E) ${message}\n" >&2
}

function program_end {
	printf "${color_off}\n"
}

function program_error {
	program_end
	exit 1
}

###############################################################
### I/O
###############################################################

# asks user for value
function display_prompt {
	local password=$1
	local variable_name=$2
	local question=$3
	local default_value=$4
	local argNo=$(expr ${5:-1} + 5)
	local args=$#
	# get value defined in argv
	if [ ${args} -ge ${argNo} ]; then
	  	variable_value=${!argNo}
	# or ask user for value
	else
		printf "${color_question_b}"
		printf "(Q) ${question}"
		if [[ -n "${default_value}" ]]; then
			printf " [${color_question_h}${default_value}${color_question_b}]"
		fi
		printf ": ${color_console}"
		if [ "$password" == "yes" ]; then
		    read -s input
		    printf "${color_off}"
		    printf "\n"
		else
		    read -e input
		    printf "${color_off}"
		fi
		# if user set nothing, then set default value
		variable_value=${input}
	fi
	set_variable "$variable_name" "$default_value" "$variable_value"
}

# asks user for variable value
function prompt_variable {
    display_prompt "no" "$@"
}

# asks user for password value
function prompt_password {
    display_prompt "yes" "$@"
}

# asks user for variable value, but accept only allowed values
function prompt_variable_fixed {
	local variable_name=$1
	local question=$2
	local default_value=$3
	local allowed_values=($4)
	shift 4
	# ask user for value from allowed list
	while true; do
		prompt_variable "$variable_name" "$question" "$default_value" "$@"
		prompt_response=`eval echo '$'"${variable_name}"`
		if test "`echo " ${allowed_values[*]} " | grep " ${prompt_response} "`"; then
	 		break
		else
			printf "${color_error_b}Wrong ${color_question_b}${question}${color_error_b}. Allowed values are ${color_error_h}${allowed_values[*]}${color_error_b}!${color_off}"
			echo ""
		fi
	done
}

# set variable value
function set_variable {
	local variable_name=$1
	local default_value=$2
	local variable_value=${3:-$default_value}
	eval "${variable_name}"'=${variable_value}'
}

# user must press y and enter, or program will end
function confirm_or_exit {
	local question=$1
	prompt_variable_fixed run "${question}" "n" "y n"
	printf "\n"
	if [[ "$run" != "y" ]]
	then
		exit -1
	fi
}
