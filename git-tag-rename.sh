#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "Rename GIT tag"
display_info "You are in ${color_info_h}`pwd`${color_info_b} directory."


## VARIABLES
prompt_variable old_tag_name "Old tag name" "" 1 "$@"
prompt_variable new_tag_name "New tag name" "" 2 "$@"


## PROGRAM
confirm_or_exit "Rename tag ${color_question_h}${old_tag_name}${color_question} to ${color_question_h}${new_tag_name}${color_question}?"

display_info "${color_success_b}Rename tag localy ${color_success_h}${old_tag_name}${color_success_b} to ${color_success_h}${new_tag_name} ${color_success}"
git tag $new_tag_name $old_tag_name

display_info "${color_error_b}Remove local old tag ${color_error_h}${old_tag_name} ${color_error}"
git tag -d $old_tag_name

display_info "${color_error_b}Remove remote old tag ${color_error_h}${old_tag_name} ${color_error}"
git push origin :refs/tags/$old_tag_name

display_info "${color_success_b}Push the new tag ${color_success_h}${new_tag_name}${color_success_b} to origin ${color_success} "
git push origin --tags
