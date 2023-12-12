#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

max_redirects=5

## TOOLS
function check_url() {
    local url="$1"
    local redirect_no="$2"
    printf "${COLOR_DEFAULT}%-40s${COLOR_OFF}" "$url"
    # shellcheck disable=SC2207
    response=($(curl -H 'Cache-Control: no-cache' -s -i -k --max-time 2 -o /dev/null --write-out '%{http_code} %{redirect_url}' "$url"))
    response_code=${response[0]}
    response_url=${response[1]}
    if [[ "$response_code" -lt "300" ]]; then
        color="$COLOR_SUCCESS"
    elif [[ "$response_code" -lt "400" ]]; then
        color="$COLOR_INFO"
    elif [[ "$response_code" -lt "500" ]]; then
        color="$COLOR_ERROR"
    else
        color="$COLOR_NOTICE"
    fi
    printf "[${color}%-3s${COLOR_OFF}]" "$response_code"
    if [[ "$response_url" != "" ]]; then
        printf " » %s" "$response_url"
    fi
    print_new_line
    if [[ "$response_code" -ge "300" ]] && [[ "$response_code" -lt "400" ]]; then
        redirect_no+=1
        if [[ "$redirect_no" -gt "$max_redirects" ]]; then
            display_error "Max redirects exceeded"
        else
            check_url "$response_url" $redirect_no
        fi
    fi
}

## WELCOME
program_title "Check URLs status code"

## VARIABLES
prompt_variable urls_list "URLs list" "$*"
# shellcheck disable=SC2206
urls_array=($urls_list)

## PROGRAM
for url in "${urls_array[@]}"; do
    display_header "$url"
    check_url "$url" 0
    print_new_line
done
