#!/usr/bin/env bash

source `dirname ${BASH_SOURCE}`/_base.sh


_branchSrc="dev"
_branchDst="master"


clear
programTitle "Merge GIT branches"

printfln "You are in ${InfoBI}`pwd`${Color_Off} directory."

promptVariable branchSrc "Source" "$_branchSrc" 1 "$@"
promptVariable branchDst "Destination" "$_branchDst" 2 "$@"
promptVariable prefix "Prefix" "" 3 "$@"
promptVariableFixed noff "With merge commit (no fast forwad)" "y" "y n" 4 "$@"

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

printfln "${BYellow}Merge ${BIYellow}${prefix}${branchSrc}${BYellow} into ${BIYellow}${prefix}${branchDst}${BYellow} ${Yellow}"
if [[ "$noff" == "y" ]]; then
	git merge ${prefix}${branchSrc} --no-ff
else
	git merge ${prefix}${branchSrc}
fi

printfln "${BGreen}Push ${BIGreen}${prefix}${branchDst}${BGreen} to upstream ${Green}"
git push origin ${prefix}${branchDst}

printfln "${BBlue}Checkout ${BIBlue}${prefix}${branchSrc}${BBlue} ${Blue} \n"
git checkout ${prefix}${branchSrc}

programEnd