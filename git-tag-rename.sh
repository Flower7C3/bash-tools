#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "Rename GIT tag"
display_info "You are in ${COLOR_INFO_H}`pwd`${COLOR_INFO_B} directory."


## VARIABLES
prompt_variable old_tag_name "Old tag name" "" 1 "$@"
prompt_variable new_tag_name "New tag name" "" 2 "$@"


## PROGRAM
confirm_or_exit "Rename tag ${COLOR_QUESTION_H}${old_tag_name}${COLOR_QUESTION} to ${COLOR_QUESTION_H}${new_tag_name}${COLOR_QUESTION}?"

display_info "${COLOR_SUCCESS_B}Rename tag localy ${COLOR_SUCCESS_H}${old_tag_name}${COLOR_SUCCESS_B} to ${COLOR_SUCCESS_H}${new_tag_name} ${COLOR_SUCCESS}"
git tag $new_tag_name $old_tag_name

display_info "${COLOR_ERROR_B}Remove local old tag ${COLOR_ERROR_H}${old_tag_name} ${COLOR_ERROR}"
git tag -d $old_tag_name

display_info "${COLOR_ERROR_B}Remove remote old tag ${COLOR_ERROR_H}${old_tag_name} ${COLOR_ERROR}"
git push origin :refs/tags/$old_tag_name

display_info "${COLOR_SUCCESS_B}Push the new tag ${COLOR_SUCCESS_H}${new_tag_name}${COLOR_SUCCESS_B} to origin ${COLOR_SUCCESS} "
git push origin --tags
