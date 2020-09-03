#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
BASE_DIR="$(pwd)/"
_git_source_url=""
_git_branch=""
_folder_to_keep=""
_git_destination_url=""
_folder_to_save=""


## WELCOME
program_title "Move files from one repository to another, preserving git history"
display_info "See article on ${COLOR_INFO_H}https://medium.com/@ayushya/move-directory-from-one-repository-to-another-preserving-git-history-d210fa049d4b${COLOR_INFO_B} site."

## VARIABLES
prompt_variable git_source_url "GIT URL of repository A" "$_git_source_url" 1 "$@"
prompt_variable git_branch "GIT branch in repository A" "$_git_branch" 2 "$@"
prompt_variable git_destination_url "GIT URL of repository B" "$_git_destination_url" 3 "$@"
prompt_variable folder_to_keep "Directory to keep from repository A" "$_folder_to_keep" 4 "$@"
prompt_variable folder_to_save "Directory to save in repository B" "$_folder_to_save" 5 "$@"

## PROGRAM
confirm_or_exit "Copy ${COLOR_QUESTION_H}${git_source_url}/${folder_to_keep}#${git_branch}${COLOR_QUESTION_B} into ${COLOR_QUESTION_H}${git_destination_url}/${folder_to_save}${COLOR_QUESTION_B}?"

display_info "Make a copy of ${COLOR_INFO_B}${git_source_url}${COLOR_INFO} as the following steps make major changes to this copy which you should not push!"
mkdir ${BASE_DIR}repoA/
cd ${BASE_DIR}repoA/
git clone --branch ${git_branch} --origin origin --progress -v ${git_source_url} .
git remote rm origin

display_info "Go through your history and files, removing anything that is not in ${COLOR_INFO_B}${folder_to_keep}${COLOR_INFO} folder. The result is the contents of that folder spewed out into the base of repository."
git filter-branch --subdirectory-filter $folder_to_keep -- --all

display_info "Clean the unwanted data."
git reset --hard
git gc --aggressive 
git prune
git clean -fd

if [[ -n "$folder_to_save" ]]; then

	display_info "Move all the files and directories to a ${COLOR_INFO_B}${folder_to_save}${COLOR_INFO} which you want to push to ${COLOR_INFO_B}repository B${COLOR_INFO}."
	mkdir $folder_to_save
	mv * $folder_to_save

	display_info "Add the changes and commit them locally"
	git add .
	git commit -m "import from ${git_source_url}/${folder_to_keep}#${git_branch}"

	display_info "Make a copy of ${COLOR_INFO_B}${git_destination_url}${COLOR_INFO} if you don’t have one already."
	mkdir ${BASE_DIR}repoB/
	cd ${BASE_DIR}repoB/
	git clone ${git_destination_url} .

	display_info "Create a remote connection to ${COLOR_INFO_B}repository A${COLOR_INFO} as a branch in ${COLOR_INFO_B}repository B${COLOR_INFO}."
	git remote add repoA ${BASE_DIR}repoA/

	display_info "Pull files and history from this branch (containing only the directory you want to move) into ${COLOR_INFO_B}repository B${COLOR_INFO}."
	git pull repoA master --allow-unrelated-histories

	display_info "Remove the remote connection to ${COLOR_INFO_B}repository A${COLOR_INFO}."
	git remote rm repoA

	display_info "Push the changes"
	git rev-parse --verify HEAD
	if [[ "$?" != "0" ]]; then
		git push -u origin master
	else
		git push
	fi

	display_info "Cleanup"
	rm -rf ${BASE_DIR}repoA/
	rm -rf ${BASE_DIR}repoB/

else

	display_info "Connect local repository to ${COLOR_INFO_B}${git_destination_url}${COLOR_INFO} repository."
	git remote add origin ${git_destination_url}

	display_info "Push the changes"
	git push -u origin master

	display_info "Cleanup"
	rm -rf ${BASE_DIR}repoA/

fi

app_bye
