#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh

## WELCOME
program_title "URL compare"
display_info "Input data file format: ${COLOR_INFO_H}example.com/old_url code example.com/new_url"

## VARIABLES
prompt_variable data_file "Input data file path" "$_data_file" 1 "$@"
if [[ ! -f "$data_file" ]]; then
    display_error "Input file does not exist!"
    exit 2
fi

## PROGRAM
confirm_or_exit "Check URLs from ${COLOR_QUESTION_H}${data_file}${COLOR_QUESTION_B} file?"

rm -rf "${data_file}.error.log"
touch "${data_file}.error.log"

mapping=($(cat $data_file))
mapping_amount=${#mapping[@]}
for index in $(seq 1 3 $mapping_amount); do
    request_url=$(echo "${mapping[$((index - 1))]}" | tr -d '\n' | tr -d '\r')
    expected_code=$(echo "${mapping[$((index))]}" | tr -d '\n' | tr -d '\r')
    expected_url=$(echo "${mapping[$((index + 1))]}" | tr -d '\n' | tr -d '\r')
    printf "%s %4d/%d %-80s " '-' "$((index / 3 + 1))" "$((mapping_amount / 3))" "$request_url"
    response=($(curl -H 'Cache-Control: no-cache' -s -i -k --max-time 2 -o /dev/null --write-out '%{http_code} %{redirect_url} ' "$request_url"))
    response_code=${response[0]}
    response_url=${response[1]}
    if [[ "$expected_code" == "$response_code" ]] && [[ "$expected_url" == "$response_url" ]]; then
        printf "${COLOR_SUCCESS}${ICON_SUCCESS} %s" "OK"
    else
        printf "${COLOR_ERROR}${ICON_ERROR} %s %s" "$response_code" "$response_url"
        printf "%s\t%s\t%s\n" "$request_url" "$response_code" "$response_url" >>"${data_file}.error.log"
    fi
    print_new_line
done

print_new_line
