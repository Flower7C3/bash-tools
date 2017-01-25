#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_method="GET"
_resourceUrl="http://127.0.0.1:8000/api/v1/pages.json"
_data=""
_contentType=""
_xdebug=" -b XDEBUG_SESSION=PHPSTORM"


## WELCOME
programTitle "REST request"


## VARIABLES
promptVariable method "Method" "$_method" 1 "$@"
promptVariable resourceUrl "Resource" "$_resourceUrl" 2 "$@"
promptVariable data "Data" "$_data" 3 "$@"

if [[ $resourceUrl == *"/auth/login"* ]]
then
  export REST_API_TOKEN=""
fi


## PROGRAM
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

programEnd
