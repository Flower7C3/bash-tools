#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_branch_src="dev"
_branch_dst="master"


## WELCOME
program_title "Merge GIT branches"
display_info "You are in ${color_info_h}`pwd`${color_info_b} directory."


## VARIABLES
prompt_variable branch_src "Source" "$_branch_src" 1 "$@"
prompt_variable branch_dst "Destination" "$_branch_dst" 2 "$@"
prompt_variable prefix "Prefix" "" 3 "$@"
prompt_variable_fixed noff "With merge commit (no fast forwad)" "y" "y n" 4 "$@"


## PROGRAM
if [[ "$noff" == "y" ]]; then
	confirm_or_exit "Merge with commit branch ${color_question_h}${prefix}${branch_src}${color_question_b} into ${color_question_h}${prefix}${branch_dst}${color_question_b}?"
else
	confirm_or_exit "Merge branch ${color_question_h}${prefix}${branch_src}${color_question_b} into ${color_question_h}${prefix}${branch_dst}${color_question_b}?"
fi

display_info "${color_success_b}Push ${color_success_h}${prefix}${branch_src}${color_success_b} to upstream ${color_success}"
git push origin ${prefix}${branch_src}

display_info "${color_notice_b}Checkout ${color_notice_h}${prefix}${branch_dst}${color_notice_b} ${color_notice}"
git checkout ${prefix}${branch_dst}

display_info "${color_error_b}Pull ${color_error_h}${prefix}${branch_dst}${color_error_b} from upstream ${Red}"
git pull origin ${prefix}${branch_dst}

if [[ "$noff" == "y" ]]; then
	display_info "${color_notice_b}Merge with commit ${color_notice_h}${prefix}${branch_src}${color_notice_b} branch into ${color_notice_h}${prefix}${branch_dst}${color_notice_b} branch${color_notice}"
	git merge ${prefix}${branch_src} --no-ff --no-edit
else
	display_info "${color_notice_b}Merge ${color_notice_h}${prefix}${branch_src}${color_notice_b} branch into ${color_notice_h}${prefix}${branch_dst}${color_notice_b} branch${color_notice}"
	git merge ${prefix}${branch_src}
fi

display_info "${color_success_b}Push ${color_success_h}${prefix}${branch_dst}${color_success_b} to upstream ${color_success}"
git push origin ${prefix}${branch_dst}

display_info "${color_notice_b}Checkout ${color_notice_h}${prefix}${branch_src}${color_notice_b} ${color_notice} \n"
git checkout ${prefix}${branch_src}

display_new_line
