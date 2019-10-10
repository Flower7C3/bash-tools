#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_method="GET"
_resource_url="http://127.0.0.1:8000/api/v1/pages.json"
_data=""
_contentType=""
_xdebug=" -b XDEBUG_SESSION=PHPSTORM"


## WELCOME
program_title "REST request"


## VARIABLES
prompt_variable method "Method" "$_method" 1 "$@"
prompt_variable resource_url "Resource" "$_resource_url" 2 "$@"
prompt_variable data "Data" "$_data" 3 "$@"

if [[ $resource_url == *"/auth/login"* ]]
then
  export REST_API_TOKEN=""
fi


## PROGRAM
printf "${color_info_b}\n"
printf "${method}: ${resource_url}\n"
printf "data: ${data}\n"
printf "${color_off}"

printf "${color_success}\n"

# if [[ $contentType = "json" ]]
# then
#   _contentType
# fi

if [[ ${REST_API_TOKEN} != "" ]]
then
  _auth="Authorization: Bearer ${REST_API_TOKEN}"
  if [ "${method}" = "GET" ]; then
    response=$(curl -v -s "${resource_url}?${data}" -H 'Content-Type:application/json' -H "${_auth}" ${_xdebug})
  else
    response=$(curl -v -s -X ${method} -d "${data}" "${resource_url}" -H "Content-Type:application/json" -H "${_auth}" ${_xdebug})
    # response=$(curl -v -s -X ${method} -d "${data}" "${resource_url}" -H "${_auth}" ${_xdebug})
  fi
else
  if [ "${method}" = "GET" ]; then
    response=$(curl -v -s "${resource_url}?${data}" -H 'Content-Type:application/json' ${_xdebug})
  else
    response=$(curl -v -s -X ${method} -d "${data}" "${resource_url}" -H "Content-Type:application/json" ${_xdebug})
    # response=$(curl -v -s -X ${method} -d "${data}" "${resource_url}" ${_xdebug})
  fi
fi
printf "${color_off}"

printf "${Green}\n"
echo ${response} | python -m json.tool

display_new_line
