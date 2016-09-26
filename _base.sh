source ${HOME}/bin/_colors.sh

function programTitle(){
	local title=$1

	printf "${BILog}"

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


function programEnd(){
	printf "${Color_Off}\n"
}


function printfln(){
	local message=$1
	printf "${message}\n"
}

# asks user for variable value
function promptVariable() {
	local variableName=$1
	local question=$2
	local defaultValue=$3
	local argNo=$(expr ${4:-1} + 4)
	local args=$#
	# get value defined in argv
	if [ $args -ge $argNo ]; then
	  	local variableValue=${!argNo}
	# or ask user for value
	else
		printf "${Color_Off}"
		printf "${question}"
		if [[ ! -z "${defaultValue}" ]]; then
			printf " [${BIYellow}${defaultValue}${Color_Off}]"
		fi
		printf ": ${On_IGreen}"
		read -e input
		# if user set nothing, then set default value
		local variableValue=$input
		printf "${Color_Off}"
	fi
	setVariable "$variableName" "$defaultValue" "$variableValue"
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
		promptResponse=`eval echo '$'"$variableName"`
		if test "`echo " ${allowedValues[*]} " | grep " ${promptResponse} "`"; then
	 		break
		else
			printf "${BIRed}Wrong ${question}. Allowed values is ${allowedValues[*]}!${Color_Off}"
			echo ""
		fi
	done
}

# set variable value
function setVariable(){
	local variableName=$1
	local defaultValue=$2
	local variableValue=${3:-$defaultValue}
	eval "$variableName"'=$variableValue' 
}

# user must press y and enter, or program will end
function confirmOrExit() {
	local question=$1
	promptVariable run "${question} [n]"
	printf "\n"
	if [[ "$run" != "y" ]]
	then
		exit -1
	fi
}
