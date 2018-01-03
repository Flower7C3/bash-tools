#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
program_title "Create GIT tag"
printfln "You are in ${color_info_h}`pwd`${color_off} directory."


## VARIABLES
prompt_variable commit_hash "Commit hash" "" 1 "$@"
prompt_variable tag_name "Tag name" "" 2 "$@"
prompt_variable tag_message "Tag message" "" 3 "$@"


## PROGRAM
confirm_or_exit "Create ${color_question_h}${tag_name}${color_question} tag in ${color_question_h}${commit_hash}${color_question} commit hash?"

printfln "${color_success_b}Get current branch ${color_success}"
current_branch=$(git branch | grep '*' | cut -d ' ' -f 2)

printfln "${color_success_b}Checkout to ${color_success_h}${commit_hash}${color_success_b} commit ${color_success}"
git checkout $commit_hash

printfln "${color_success_b}Create new ${color_success_h}${tag_name}${color_success_b} tag with ${color_success_h}${tag_message}${color_success_b} message ${color_success}"
git tag -a "$tag_name" -m "$tag_message"

printfln "${color_success_b}Push the new tag ${color_success_h}${new_tag_name}${color_success_b} to origin ${color_success} "
git push origin --tags

printfln "${color_success_b}Checkout to ${color_success_h}${current_branch}${color_success_b} branch ${color_success}"
git checkout $current_branch
