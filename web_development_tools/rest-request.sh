#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh


## CONFIG
_method="GET"
_resource_url="http://127.0.0.1:8000/api/v1/pages.json"
_data=""
_xdebug=" -b XDEBUG_SESSION=PHPSTORM"
_auth_type=${REST_AUTH_TYPE:-"Bearer"}
_auth_credentials=${REST_AUTH_CREDENTIALS:-""}
_content_type="application/json"

## WELCOME
program_title "REST request"


## VARIABLES
prompt_variable method "Method" "$_method" 1 "$@"
prompt_variable resource_url "Resource" "$_resource_url" 2 "$@"
prompt_variable data "Data" "$_data" 3 "$@"
prompt_variable auth_type "REST auth type" "$_auth_type" 4 "$@"
prompt_variable auth_credentials "REST auth credentials" "$_auth_credentials" 5 "$@"
prompt_variable content_type "Content type" "$_content_type" 6 "$@"

## PROGRAM
printf "${COLOR_INFO_B}\n"
printf "${method}: ${resource_url}\n"
printf "Authorization: ${auth_type} ${auth_credentials}\n"
printf "Payload: ${data:-'empty'}\n"
color_reset

printf "${COLOR_SUCCESS}\n"

if [[ ${auth_type} != "" ]] || [[ ${auth_credentials} != "" ]]; then
    header_auth=' -H "Authorization: '"${auth_type} ${auth_credentials}"'"'
else
    header_auth=""
fi
if [[ ${content_type} != "" ]]; then
    header_content_type=' -H "Content-Type:'${content_type}'"'
else
    header_content_type=""
fi
if [ "${method}" = "GET" ]; then
    response=$(eval curl -v -s "${resource_url}?${data}" ${header_content_type} ${header_auth} ${_xdebug})
else
    response=$(eval curl -v -s -X ${method} -d "${data}" "${resource_url}" ${header_content_type} ${header_auth} ${_xdebug})
fi
color_reset

printf "${COLOR_GREEN}\n"
echo ${response} | python -m json.tool

print_new_line
