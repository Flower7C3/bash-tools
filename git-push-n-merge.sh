clear

source `dirname $0`/colors.sh

printf "Current path: ${On_IGreen}`pwd`${Color_Off}\n"

_branchSrc="dev"
_branchDst="master"

if [ $# -ge 1 ]
then
  prefix=$1
else
  printf "Prefix: ${On_IGreen}"
  read -e prefix
  printf "${Color_Off}"
fi

if [ $# -ge 2 ]
then
  branchSrc=$2
else
  printf "Source [${BIYellow}${_branchSrc}${Color_Off}]: ${On_IGreen}"
  read -e input
  branchSrc=${input:-$_branchSrc}
  printf "${Color_Off}"
fi

if [ $# -ge 3 ]
then
  branchDst=$3
else
  printf "Destination [${BIYellow}${_branchDst}${Color_Off}]: ${On_IGreen}"
  read -e input
  branchDst=${input:-$_branchDst}
  printf "${Color_Off}"
fi

printf "Merge branch ${BIYellow}${prefix}${branchSrc}${Color_Off} into ${BIYellow}${prefix}${branchDst}${Color_Off}? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

  printf "${BGreen}Push ${BIGreen}${prefix}${branchSrc}${BGreen} to upstream ${Green} \n"
  git push

  printf "${BBlue}Checkout ${BIBlue}${prefix}${branchDst}${BBlue} ${Blue} \n"
  git checkout ${prefix}${branchDst}

  printf "${BRed}Pull ${BIRed}${prefix}${branchDst}${BRed} from upstream ${Red} \n"
  git pull

  printf "${BYellow}Merge ${BIYellow}${prefix}${branchSrc}${BYellow} into ${BIYellow}${prefix}${branchDst}${BYellow} ${Yellow} \n"
  git merge ${prefix}${branchSrc}

  printf "${BGreen}Push ${BIGreen}${prefix}${branchDst}${BGreen} to upstream ${Green} \n"
  git push

  printf "${BBlue}Checkout ${BIBlue}${prefix}${branchSrc}${BBlue} ${Blue} \n"
  git checkout ${prefix}${branchSrc}

  printf "${Color_Off}"

fi

