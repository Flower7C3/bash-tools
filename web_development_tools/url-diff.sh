#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
_pages="/"

## WELCOME
program_title "Compare two pates content"

## VARIABLES
prompt_variable_not_null domain_one "Domain one address" "" 1 "$@"
prompt_variable_not_null domain_two "Domain two address" "" 2 "$@"
prompt_variable_not_null pages "Pages" "$_pages" 3 "$@"
pages=($pages)

# PROGRAM
confirm_or_exit "Compare ${domain_one} vs ${domain_two}?"

for index in "${!pages[@]}"; do
    page=${pages[$index]}
    echo "> PAGE $page <"
    url_one="$domain_one$page"
    url_two="$domain_two$page"
    # status_one=$(curl -s -o /dev/null -w "%{http_code}" "$url_one")
    # status_two=$(curl -s -o /dev/null -w "%{http_code}" "$url_two")
    content_one=$(curl -s -L $url_one)
    content_two=$(curl -s -L $url_two)
    if [[ "$content_one" == "$content_two" ]]; then
        printf "${COLOR_SUCCESS}SAME${COLOR_OFF}\n"
    else
        printf "${COLOR_ERROR}DIFFERENT${COLOR_OFF}\n"
        printf "${#content_one}\n"
        printf "${#content_two}\n"
    fi
done

print_new_line
