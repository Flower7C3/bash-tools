#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## WELCOME
programTitle "Rename GIT branch"
printfln "You are in ${InfoBI}`pwd`${Color_Off} directory."


## VARIABLES
promptVariable old_branch "Old branch name" "" 1 "$@"
promptVariable new_branch "New branch name" "" 2 "$@"


## PROGRAM
confirmOrExit "Rename branch ${QuestionBI}${old_branch}${Question} to ${QuestionBI}${new_branch}${Question}?"

printfln "${BGreen}Rename branch localy ${BIGreen}${old_branch}${BGreen} to ${BIGreen}${new_branch} ${Blue}"
git branch -m $old_branch $new_branch

printfln "${BGreen}Remove remote old branch ${BIGreen}${old_branch} ${Red}"
git push origin :$old_branch 

printfln "${BGreen}Push the new branch ${BIGreen}${new_branch}${BGreen} and set local branch to track the new remote ${BGreen} "
git push --set-upstream origin $new_branch

programEnd
