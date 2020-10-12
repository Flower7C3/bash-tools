#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_remote_src="origin"
_remote_dst="origin2"
_branch="master"


## WELCOME
program_title "Synchronize remote GIT branches"
display_info "You are in ${COLOR_INFO_H}`pwd`${COLOR_INFO_B} directory."


## VARIABLES
prompt_variable remote_src "Source remote" "$_remote_src" 1 "$@"
prompt_variable remote_dst "Destination remote" "$_remote_dst" 2 "$@"
prompt_variable branch "Branch" "" 3 "$@"


## PROGRAM
confirm_or_exit "Pull branch ${COLOR_QUESTION_H}${branch}${COLOR_QUESTION_B} from ${COLOR_QUESTION_H}${remote_src}${COLOR_QUESTION_B} and push to ${COLOR_QUESTION_H}${remote_dst}${COLOR_QUESTION_B}?"

display_info "${COLOR_SUCCESS_B}Pull ${COLOR_SUCCESS_H}${branch}${COLOR_SUCCESS_B} from ${COLOR_SUCCESS_H}${remote_src}${COLOR_SUCCESS_B} remote ${COLOR_SUCCESS}"
git pull $remote_src $branch

display_info "${COLOR_SUCCESS_B}Push ${COLOR_SUCCESS_H}${branch}${COLOR_SUCCESS_B} to ${COLOR_SUCCESS_H}${remote_dst}${COLOR_SUCCESS_B} remote ${COLOR_SUCCESS}"
git push $remote_dst $branch

print_new_line
