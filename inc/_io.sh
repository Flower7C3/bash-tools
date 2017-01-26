###############################################################
### Program info
###############################################################

function programTitle(){
	local title=$1

	printf "${LogBI}"

	printf "${BoxTL}${BoxH}"
	for (( c=1; c<=${#title} ; c++ ))
	do
	   printf "${BoxH}"
	done
	printf "${BoxH}${BoxTR}\n"

	printf "${BoxV} ${title} ${BoxV}\n"

	printf "${BoxBL}${BoxH}"
	for (( c=1; c<=${#title} ; c++ ))
	do
	   printf "${BoxH}"
	done
	printf "${BoxH}${BoxBR}\n"
	
	printf "${Color_Off}"
}

function printfln(){
	local message=$1
	printf "${message}\n"
}

function displayInfo(){
    local message=$1
    printf "${InfoB}(I) ${message}\n"
}

function displayError(){
    local message=$1
    printf "${ErrorB}(E) ${message}\n"
}

function programEnd(){
	printf "${Color_Off}\n"
}

function programError(){
	programEnd
	exit 1
}

###############################################################
### I/O
###############################################################

# asks user for value
function displayPrompt() {
	local password=$1
	local variableName=$2
	local question=$3
	local defaultValue=$4
	local argNo=$(expr ${5:-1} + 5)
	local args=$#
	# get value defined in argv
	if [ ${args} -ge ${argNo} ]; then
	  	variableValue=${!argNo}
	# or ask user for value
	else
		printf "${QuestionB}"
		printf "(Q) ${question}"
		if [[ -n "${defaultValue}" ]]; then
			printf " [${QuestionBI}${defaultValue}${QuestionB}]"
		fi
		printf ": ${On_IGreen}"
		if [ "$password" == "yes" ]; then
		    read -s input
		    printf "\n"
		else
		    read -e input
		fi
		# if user set nothing, then set default value
		variableValue=${input}
		printf "${Color_Off}"
	fi
	setVariable "$variableName" "$defaultValue" "$variableValue"
}

# asks user for variable value
function promptVariable() {
    displayPrompt "no" "$@"
}

# asks user for password value
function promptPassword() {
    displayPrompt "yes" "$@"
}

# asks user for variable value, but accept only allowed values
function promptVariableFixed() {
	local variableName=$1
	local question=$2
	local defaultValue=$3
	local allowedValues=($4)
	shift 4
	# ask user for value from allowed list
	while true; do
		promptVariable "$variableName" "$question" "$defaultValue" "$@"
		promptResponse=`eval echo '$'"${variableName}"`
		if test "`echo " ${allowedValues[*]} " | grep " ${promptResponse} "`"; then
	 		break
		else
			printf "${BRed}Wrong ${QuestionB}${question}${BRed}. Allowed values are ${BIRed}${allowedValues[*]}${BRed}!${Color_Off}"
			echo ""
		fi
	done
}

# set variable value
function setVariable(){
	local variableName=$1
	local defaultValue=$2
	local variableValue=${3:-$defaultValue}
	eval "${variableName}"'=${variableValue}'
}

# user must press y and enter, or program will end
function confirmOrExit() {
	local question=$1
	promptVariableFixed run "${question}" "n" "y n"
	printf "\n"
	if [[ "$run" != "y" ]]
	then
		exit -1
	fi
}
