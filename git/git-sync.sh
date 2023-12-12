#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
_branches="master,dev"

## WELCOME
program_title "Synch GIT branches"
printf "You are in ${COLOR_INFO_H}$(pwd)${COLOR_OFF} directory.\n"

## VARIABLES
prompt_variable branches "Branches" "$_branches" 1 "$@"
OLD_IFS=$IFS
IFS=',' read -a branches <<<"$branches"
IFS=$OLD_IFS
prompt_variable prefix "Prefix" "" 2 "$@"

## PROGRAM
confirm_or_exit "$(
    printf "Pull branches"
    for branch in "${branches[@]}"; do printf " ${COLOR_QUESTION_H}${prefix}${branch}${COLOR_QUESTION}"; done
    printf "?"
)"

for branch in "${branches[@]}"; do

    printf "${COLOR_INFO_B}Checkout ${COLOR_INFO_H}${prefix}${branch}${COLOR_INFO_B} ${COLOR_INFO} \n"
    git checkout ${prefix}${branch}

    printf "${COLOR_INFO_B}Pull ${COLOR_INFO_H}${prefix}${branch}${COLOR_INFO_B} from upstream ${COLOR_INFO} \n"
    git pull

done

print_new_line
