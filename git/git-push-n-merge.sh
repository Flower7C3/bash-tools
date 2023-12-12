#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

## CONFIG
_branch_src="dev"
_branch_dst="master"

## WELCOME
program_title "Merge GIT branches"
display_info "You are in ${COLOR_INFO_H}$(pwd)${COLOR_INFO_B} directory."

## VARIABLES
prompt_variable branch_src "Source" "$_branch_src" 1 "$@"
prompt_variable branch_dst "Destination" "$_branch_dst" 2 "$@"
prompt_variable prefix "Prefix" "" 3 "$@"
prompt_variable_fixed noff "With merge commit (no fast forward)" "y" "y n" 4 "$@"

## PROGRAM
if [[ "$noff" == "y" ]]; then
    confirm_or_exit "Merge with commit branch ${COLOR_QUESTION_H}${prefix}${branch_src}${COLOR_QUESTION_B} into ${COLOR_QUESTION_H}${prefix}${branch_dst}${COLOR_QUESTION_B}?"
else
    confirm_or_exit "Merge branch ${COLOR_QUESTION_H}${prefix}${branch_src}${COLOR_QUESTION_B} into ${COLOR_QUESTION_H}${prefix}${branch_dst}${COLOR_QUESTION_B}?"
fi

#display_info "${COLOR_NOTICE_B}Stash current changes${COLOR_NOTICE}"
#git stash

display_info "${COLOR_NOTICE_B}Checkout source branch ${COLOR_NOTICE_H}${prefix}${branch_src}${COLOR_NOTICE_B} ${COLOR_NOTICE}"
git checkout ${prefix}${branch_src}

display_success "${COLOR_SUCCESS_B}Push ${COLOR_SUCCESS_H}${prefix}${branch_src}${COLOR_SUCCESS_B} to upstream ${COLOR_SUCCESS}"
git push origin ${prefix}${branch_src}

display_info "${COLOR_NOTICE_B}Checkout previous branch ${COLOR_NOTICE}"
git checkout -

display_info "${COLOR_NOTICE_B}Checkout destination branch ${COLOR_NOTICE_H}${prefix}${branch_dst}${COLOR_NOTICE_B} ${COLOR_NOTICE}"
git checkout ${prefix}${branch_dst}

display_info "${COLOR_ERROR_B}Pull ${COLOR_ERROR_H}${prefix}${branch_dst}${COLOR_ERROR_B} from upstream ${COLOR_RED}"
git pull origin ${prefix}${branch_dst}

if [[ "$noff" == "y" ]]; then
    display_info "${COLOR_NOTICE_B}Merge with commit ${COLOR_NOTICE_H}${prefix}${branch_src}${COLOR_NOTICE_B} branch into ${COLOR_NOTICE_H}${prefix}${branch_dst}${COLOR_NOTICE_B} branch${COLOR_NOTICE}"
    git merge ${prefix}${branch_src} --no-ff --no-edit
else
    display_info "${COLOR_NOTICE_B}Merge ${COLOR_NOTICE_H}${prefix}${branch_src}${COLOR_NOTICE_B} branch into ${COLOR_NOTICE_H}${prefix}${branch_dst}${COLOR_NOTICE_B} branch${COLOR_NOTICE}"
    git merge ${prefix}${branch_src}
fi

display_success "${COLOR_SUCCESS_B}Push ${COLOR_SUCCESS_H}${prefix}${branch_dst}${COLOR_SUCCESS_B} to upstream ${COLOR_SUCCESS}"
git push origin ${prefix}${branch_dst}

display_info "${COLOR_NOTICE_B}Checkout previous branch ${COLOR_NOTICE}"
git checkout -

#display_info "${COLOR_NOTICE_B}Restore changes ${COLOR_NOTICE} \n"
#git stash pop

print_new_line
