#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh


## CONFIG
_branches="master,dev"


## WELCOME
programTitle "Synch GIT branches"
printf "You are in ${InfoBI}`pwd`${Color_Off} directory.\n"


## VARIABLES
promptVariable branches "Branches" "$_branches" 1 "$@"
IFS=',' read -a branches <<< "$branches"
promptVariable prefix "Prefix" "" 2 "$@"


## PROGRAM
confirmOrExit "$(printf "Pull branches"; for branch in "${branches[@]}"; do printf " ${QuestionBI}${prefix}${branch}${Question}"; done; printf "?")"

for branch in "${branches[@]}"
do

  printf "${BBlue}Checkout ${BIBlue}${prefix}${branch}${BBlue} ${Blue} \n"
  git checkout ${prefix}${branch}

  printf "${BRed}Pull ${BIRed}${prefix}${branch}${BRed} from upstream ${Red} \n"
  git pull

done

programEnd
