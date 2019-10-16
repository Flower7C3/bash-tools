#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "Rename GIT branch"
display_info "You are in ${color_info_h}`pwd`${color_info_b} directory."


## VARIABLES
prompt_variable old_branch "Old branch name" "" 1 "$@"
prompt_variable new_branch "New branch name" "" 2 "$@"


## PROGRAM
confirm_or_exit "Rename branch ${color_question_h}${old_branch}${color_question} to ${color_question_h}${new_branch}${color_question}?"

display_info "${color_success_b}Rename branch localy ${color_success_h}${old_branch}${color_success_b} to ${color_success_h}${new_branch} ${color_success}"
git branch -m $old_branch $new_branch

display_info "${color_error_b}Remove remote old branch ${color_error_h}${old_branch} ${color_error}"
git push origin :$old_branch 

display_info "${color_success_b}Push the new branch ${color_success_h}${new_branch}${color_success_b} and set local branch to track the new remote ${color_success} "
git push --set-upstream origin $new_branch

print_new_line
