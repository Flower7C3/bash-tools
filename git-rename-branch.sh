#!/usr/bin/env bash

clear

source `dirname $0`/colors.sh

printf "Current path: ${On_IGreen}`pwd`${Color_Off}\n"

if [ $# -ge 1 ]
then
  old_branch=$1
else
  printf "Old branch name: ${On_IGreen}"
  read -e input
  old_branch=${input}
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  new_branch=$2
else
  printf "New branch name: ${On_IGreen}"
  read -e input
  new_branch=${input}
  printf "${Color_Off}"
fi

printf "Rename branch ${BIYellow}${old_branch}${Color_Off} to ${BIYellow}${new_branch}${Color_Off}? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

  printf "${BGreen}Rename branch localy ${BIGreen}${old_branch}${BGreen} to ${BIGreen}${new_branch} ${Blue} \n"
  git branch -m $old_branch $new_branch

  printf "${BGreen}Remove remote old branch ${BIGreen}${old_branch} ${Red} \n"
  git push origin :$old_branch 

  printf "${BGreen}Push the new branch ${BIGreen}${new_branch}${BGreen} and set local branch to track the new remote ${BGreen}  \n"
  git push --set-upstream origin $new_branch

fi

printf "${Color_Off}"
