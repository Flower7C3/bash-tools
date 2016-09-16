source `dirname $0`/_colors.sh

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


function promptVariable() {
	local variableName=$1
	local question=$2
	local defaultValue=$3
	if [ $# -ge 4 ]
	then
	  	local variableValue=$4
	else
		printf "${Color_Off}${question}: ${On_IGreen}"
		read -e input
		local variableValue=${input:-$defaultValue}
		printf "${Color_Off}"
	fi
	eval "$variableName"'=$variableValue' 
}


function setVariable(){
	local variableName=$1
	local defaultValue=$2
	local variableValue=${3:-$defaultValue}
	eval "$variableName"'=$variableValue' 
}


function confirmOrExit() {
	local question=$1
	promptVariable run "${question} [n]"
	if [[ "$run" != "y" ]]
	then
		exit -1
	fi
}
