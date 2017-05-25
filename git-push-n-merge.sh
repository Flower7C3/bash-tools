#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


## CONFIG
_branchSrc="dev"
_branchDst="master"


## WELCOME
programTitle "Merge GIT branches"
printfln "You are in ${InfoBI}`pwd`${Color_Off} directory."


## VARIABLES
promptVariable branchSrc "Source" "$_branchSrc" 1 "$@"
promptVariable branchDst "Destination" "$_branchDst" 2 "$@"
promptVariable prefix "Prefix" "" 3 "$@"
promptVariableFixed noff "With merge commit (no fast forwad)" "y" "y n" 4 "$@"


## PROGRAM
if [[ "$noff" == "y" ]]; then
	confirmOrExit "Merge with commit branch ${QuestionBI}${prefix}${branchSrc}${QuestionB} into ${QuestionBI}${prefix}${branchDst}${QuestionB}?"
else
	confirmOrExit "Merge branch ${QuestionBI}${prefix}${branchSrc}${QuestionB} into ${QuestionBI}${prefix}${branchDst}${QuestionB}?"
fi

printfln "${BGreen}Push ${BIGreen}${prefix}${branchSrc}${BGreen} to upstream ${Green}"
git push origin ${prefix}${branchSrc}

printfln "${BBlue}Checkout ${BIBlue}${prefix}${branchDst}${BBlue} ${Blue}"
git checkout ${prefix}${branchDst}

printfln "${BRed}Pull ${BIRed}${prefix}${branchDst}${BRed} from upstream ${Red}"
git pull origin ${prefix}${branchDst}

if [[ "$noff" == "y" ]]; then
	printfln "${BYellow}Merge with commit ${BIYellow}${prefix}${branchSrc}${BYellow} branch into ${BIYellow}${prefix}${branchDst}${BYellow} branch${Yellow}"
	git merge ${prefix}${branchSrc} --no-ff --no-edit
else
	printfln "${BYellow}Merge ${BIYellow}${prefix}${branchSrc}${BYellow} branch into ${BIYellow}${prefix}${branchDst}${BYellow} branch${Yellow}"
	git merge ${prefix}${branchSrc}
fi

printfln "${BGreen}Push ${BIGreen}${prefix}${branchDst}${BGreen} to upstream ${Green}"
git push origin ${prefix}${branchDst}

printfln "${BBlue}Checkout ${BIBlue}${prefix}${branchSrc}${BBlue} ${Blue} \n"
git checkout ${prefix}${branchSrc}

programEnd