#!/usr/bin/env bash

source `dirname $0`/_base.sh


_branches="master,dev"


clear
programTitle "Synch GIT branches"

printf "You are in ${BIYellow}`pwd`${Color_Off} directory.\n"

promptVariable branches "Branches [${BIYellow}${_branches}${Color_Off}]" "$_branches" $1
IFS=',' read -a branches <<< "$branches"
promptVariable prefix "Prefix (no default value)" "" $3

confirmOrExit "`printf "Pull branches"; for branch in "${branches[@]}"; do printf " ${BIYellow}${prefix}${branch}${Color_Off}"; done; printf "?"`"

for branch in "${branches[@]}"
do

  printf "${BBlue}Checkout ${BIBlue}${prefix}${branch}${BBlue} ${Blue} \n"
  git checkout ${prefix}${branch}

  printf "${BRed}Pull ${BIRed}${prefix}${branch}${BRed} from upstream ${Red} \n"
  git pull

done

programEnd
