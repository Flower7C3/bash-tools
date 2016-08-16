clear

source `dirname $0`/colors.sh

_method="GET"
_resourceUrl="http://127.0.0.1:8000/api/v1/pages.json"
_data=""
_contentType=""
_xdebug=" -b XDEBUG_SESSION=PHPSTORM"

if [ $# -ge 1 ]
then
  method=$1
else
  printf "Method [${BIYellow}${_method}${Color_Off}]: ${On_IGreen}"
  read -e input
  method=${input:-$_method}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  resourceUrl=$2
else
  printf "Resource [${BIYellow}${_resourceUrl}${Color_Off}]: ${On_IGreen}"
  read -e input
  resourceUrl=${input:-$_resourceUrl}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
  data=$3
else
  printf "Data [${BIYellow}${_data}${Color_Off}]: ${On_IGreen}"
  read -e input
  data=${input:-$_data}
  printf "${Color_Off}"
fi

# if [ $# -ge 4 ]
# then
#   contentType=$4
# else
#   printf "Content-Type [${BIYellow}${_contentType}${Color_Off}]: ${On_IGreen}"
#   read -e input
#   contentType=${input:-$_contentType}
#   printf "${Color_Off}"
# fi

if [[ $resourceUrl == *"/auth/login"* ]]
then
  export REST_API_TOKEN=""
fi


printf "${BBlue}\n"
printf "${method}: ${resourceUrl}\n"
printf "data: ${data}\n"
printf "${Color_Off}"

printf "${Magenta}\n"

# if [[ $contentType = "json" ]]
# then
#   _contentType
# fi

if [[ $REST_API_TOKEN != "" ]]
then
  _auth="Authorization: Bearer ${REST_API_TOKEN}"
  if [ "${method}" = "GET" ]; then
    response=$(curl -v -s "${resourceUrl}?${data}" -H 'Content-Type:application/json' -H "${_auth}" ${_xdebug})
  else
    response=$(curl -v -s -X ${method} -d "${data}" "${resourceUrl}" -H "Content-Type:application/json" -H "${_auth}" ${_xdebug})
    # response=$(curl -v -s -X ${method} -d "${data}" "${resourceUrl}" -H "${_auth}" ${_xdebug})
  fi
else
  if [ "${method}" = "GET" ]; then
    response=$(curl -v -s "${resourceUrl}?${data}" -H 'Content-Type:application/json' ${_xdebug})
  else
    response=$(curl -v -s -X ${method} -d "${data}" "${resourceUrl}" -H "Content-Type:application/json" ${_xdebug})
    # response=$(curl -v -s -X ${method} -d "${data}" "${resourceUrl}" ${_xdebug})
  fi
fi
printf "${Color_Off}"

printf "${Green}\n"
echo $response | python -m json.tool
printf "${Color_Off}"

printf "\n\n"
