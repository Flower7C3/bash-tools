source `dirname ${BASH_SOURCE}`/_colors.sh


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


function programEnd(){
	printf "${Color_Off}\n"
}


###############################################################
### I/O
###############################################################

function displayInfo(){
    local message=$1
    printf "${InfoB}(I) ${message}\n"
}

function displayError(){
    local message=$1
    printf "${ErrorB}(E) ${message}\n"
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
	if [ ${args} -ge ${argNo} ]; then
	  	local variableValue=${!argNo}
	# or ask user for value
	else
		printf "${QuestionB}"
		printf "(Q) ${question}"
		if [[ ! -z "${defaultValue}" ]]; then
			printf " [${QuestionBI}${defaultValue}${QuestionB}]"
		fi
		printf ": ${On_IGreen}"
		read -e input
		# if user set nothing, then set default value
		local variableValue=${input}
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
		promptResponse=`eval echo '$'"${variableName}"`
		if test "`echo " ${allowedValues[*]} " | grep " ${promptResponse} "`"; then
	 		break
		else
			printf "${ErrorB}Wrong value for ${QuestionB}${question}${ErrorB} question. Allowed values are: ${ErrorBI}%s${ErrorB}!${Color_Off}" $( IFS=$','; printf "${allowedValues[*]}" )
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

###############################################################
### Facebook cache
###############################################################

function facebook_cache_clean_by_sitemap {
    local baseURL=${1:-http://localhost/}
    local sitemapFile=${2:-sitemap.xml}

    printf "${InfoB}Clean facebook cache for ${InfoBI}${baseURL}${InfoB} ${Info} \n"
    wget -q ${baseURL} --no-check-certificate --no-cache -O - | egrep -o "${baseURL}[^ \"()\<>]*" | while read url;
    do
  		facebook_cache_clean $url
    done
}


function facebook_cache_clean {
    local url=${1:-http://localhost/}

    printf "${InfoB}Clean facebook cache for ${InfoBI}${url}${InfoB} page${Color_Off} \n"
    curl -X POST \
        -F "id=${url}" \
        -F "scrape=true" \
        "https://graph.facebook.com"
    echo ""
}
