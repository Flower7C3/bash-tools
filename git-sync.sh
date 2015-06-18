clear

source `dirname $0`/colors.sh

printf "Current path: ${On_IGreen}`pwd`${Color_Off}\n"

_branches="master,dev"

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
  branches=$2
else
  printf "Branches [${BIYellow}${_branches}${Color_Off}]: ${On_IGreen}"
  read -e input
  branches=${input:-$_branches}
  printf "${Color_Off}"
fi
IFS=',' read -a branches <<< "$branches"

printf "Pull branches"
for branch in "${branches[@]}"
do
  printf " ${BIYellow}${prefix}${branch}${Color_Off}"
done
printf "? [n]: ${On_IGreen}"

read -e input
printf "${Color_Off}"
run=${input:-n}

if [[ "$run" == "y" ]]
then

  for branch in "${branches[@]}"
  do

    printf "${BBlue}Checkout ${BIBlue}${prefix}${branch}${BBlue} ${Blue} \n"
    git checkout ${prefix}${branch}

    printf "${BRed}Pull ${BIRed}${prefix}${branch}${BRed} from upstream ${Red} \n"
    git pull

  done

  printf "${Color_Off}"

fi

