#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_branches="master,dev"


## WELCOME
program_title "Synch GIT branches"
printf "You are in ${color_info_h}`pwd`${color_off} directory.\n"


## VARIABLES
prompt_variable branches "Branches" "$_branches" 1 "$@"
IFS=',' read -a branches <<< "$branches"
prompt_variable prefix "Prefix" "" 2 "$@"


## PROGRAM
confirm_or_exit "$(printf "Pull branches"; for branch in "${branches[@]}"; do printf " ${color_question_h}${prefix}${branch}${color_question}"; done; printf "?")"

for branch in "${branches[@]}"
do

  printf "${color_info_b}Checkout ${color_info_h}${prefix}${branch}${color_info_b} ${color_info} \n"
  git checkout ${prefix}${branch}

  printf "${color_info_b}Pull ${color_info_h}${prefix}${branch}${color_info_b} from upstream ${color_info} \n"
  git pull

done

program_end
