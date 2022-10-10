#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/../_inc/_base.sh


## WELCOME
program_title "Create GIT tag"
display_info "You are in ${COLOR_INFO_H}`pwd`${COLOR_OFF} directory."


## VARIABLES
prompt_variable commit_hash "Commit hash" "" 1 "$@"
prompt_variable tag_name "Tag name" "" 2 "$@"
prompt_variable tag_message "Tag message" "" 3 "$@"


## PROGRAM
confirm_or_exit "Create ${COLOR_QUESTION_H}${tag_name}${COLOR_QUESTION} tag in ${COLOR_QUESTION_H}${commit_hash}${COLOR_QUESTION} commit hash?"

display_info "${COLOR_SUCCESS_B}Get current branch ${COLOR_SUCCESS}"
current_branch=$(git branch | grep '*' | cut -d ' ' -f 2)

display_info "${COLOR_SUCCESS_B}Checkout to ${COLOR_SUCCESS_H}${commit_hash}${COLOR_SUCCESS_B} commit ${COLOR_SUCCESS}"
git checkout $commit_hash

display_info "${COLOR_SUCCESS_B}Create new ${COLOR_SUCCESS_H}${tag_name}${COLOR_SUCCESS_B} tag with ${COLOR_SUCCESS_H}${tag_message}${COLOR_SUCCESS_B} message ${COLOR_SUCCESS}"
git tag -a "$tag_name" -m "$tag_message"

display_info "${COLOR_SUCCESS_B}Push the new tag ${COLOR_SUCCESS_H}${new_tag_name}${COLOR_SUCCESS_B} to origin ${COLOR_SUCCESS} "
git push origin --tags

display_info "${COLOR_SUCCESS_B}Checkout to ${COLOR_SUCCESS_H}${current_branch}${COLOR_SUCCESS_B} branch ${COLOR_SUCCESS}"
git checkout $current_branch
