#!/usr/bin/env bash

cd `dirname $0`
source colors.sh
clear

host_src=${1:-"source-host"}
home_src=${2:-'~/master/'}

host_dst=${3:-"destination-host"}
home_dst=${4:-'~/dev/'}

backup_path=${5:-"vendor/"}

date=`date "+%Y%m%d-%H%M%S"`
backup_file='vendors-'$date'.tar'
home_local="${HOME}/"


printf "${BBlue}Prepare directory ${BIBlue}${home_src}${backup_path}${BBlue} at ${BIBlue}${host_src}${BBlue} host ${Blue} \n"
ssh ${host_src} "cd "${home_src}";tar -cf "${home_src}${backup_file}" "${backup_path}
ssh ${host_dst} "rm -rf "${home_dst}${backup_path}"*"
printf "${Color_Off}"

printf "${BGreen}Copy from source ${BIGreen}${host_src}${BGreen} host to destination ${BIGreen}${host_dst}${BGreen} host ${Green} \n"
scp ${host_src}:${home_src}${backup_file} ${home_local}${backup_file}
scp ${home_local}${backup_file} ${host_dst}:${home_dst}${backup_file}
printf "${Color_Off}"

printf "${BGreen}Extract ${BIGreen}${backup_file}${BGreen} file to ${BIGreen}${home_dst}${backup_path}${BGreen} path at ${BIGreen}${host_dst}${BGreen} host ${Green} \n"
ssh ${host_dst} "cd "${home_dst}"; tar -xf "${home_dst}${backup_file}
printf "${Color_Off}"

printf "${BRed}Cleanup${Red} \n"
ssh ${host_src} "rm "${home_src}${backup_file}
ssh ${host_dst} "rm "${home_dst}${backup_file}
rm ${home_local}${backup_file}
printf "${Color_Off}"
