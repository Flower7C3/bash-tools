#!/usr/bin/env bash

source `dirname $0`/_base.sh


_branchSrc="dev"
_branchDst="master"


clear
programTitle "Merge GIT branches"

printfln "You are in ${BIYellow}`pwd`${Color_Off} directory."

promptVariable branchSrc "Source" "$_branchSrc" 1 "$@"
promptVariable branchDst "Destination" "$_branchDst" 2 "$@"

promptVariable prefix "Prefix (no default value)" "" 3 "$@"

confirmOrExit "Merge branch ${BIYellow}${prefix}${branchSrc}${Color_Off} into ${BIYellow}${prefix}${branchDst}${Color_Off}?"

printfln "${BGreen}Push ${BIGreen}${prefix}${branchSrc}${BGreen} to upstream ${Green}"
git push

printfln "${BBlue}Checkout ${BIBlue}${prefix}${branchDst}${BBlue} ${Blue}"
git checkout ${prefix}${branchDst}

printfln "${BRed}Pull ${BIRed}${prefix}${branchDst}${BRed} from upstream ${Red}"
git pull

printfln "${BYellow}Merge ${BIYellow}${prefix}${branchSrc}${BYellow} into ${BIYellow}${prefix}${branchDst}${BYellow} ${Yellow}"
git merge ${prefix}${branchSrc}

printfln "${BGreen}Push ${BIGreen}${prefix}${branchDst}${BGreen} to upstream ${Green}"
git push

printfln "${BBlue}Checkout ${BIBlue}${prefix}${branchSrc}${BBlue} ${Blue} \n"
git checkout ${prefix}${branchSrc}

programEnd