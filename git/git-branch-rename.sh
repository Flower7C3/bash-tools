#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## WELCOME
program_title "Rename GIT branch"
display_info "You are in ${COLOR_INFO_H}$(pwd)${COLOR_INFO_B} directory."

## VARIABLES
prompt_variable old_branch "Old branch name" "" 1 "$@"
prompt_variable new_branch "New branch name" "" 2 "$@"

## PROGRAM
confirm_or_exit "Rename branch ${COLOR_QUESTION_H}${old_branch}${COLOR_QUESTION} to ${COLOR_QUESTION_H}${new_branch}${COLOR_QUESTION}?"

display_info "${COLOR_SUCCESS_B}Rename branch localy ${COLOR_SUCCESS_H}${old_branch}${COLOR_SUCCESS_B} to ${COLOR_SUCCESS_H}${new_branch} ${COLOR_SUCCESS}"
git branch -m $old_branch $new_branch

display_info "${COLOR_ERROR_B}Remove remote old branch ${COLOR_ERROR_H}${old_branch} ${COLOR_ERROR}"
git push origin :$old_branch

display_info "${COLOR_SUCCESS_B}Push the new branch ${COLOR_SUCCESS_H}${new_branch}${COLOR_SUCCESS_B} and set local branch to track the new remote ${COLOR_SUCCESS} "
git push --set-upstream origin $new_branch

print_new_line
