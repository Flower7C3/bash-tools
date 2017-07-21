#!/usr/bin/env bash

source $(dirname ${BASH_SOURCE})/_base.sh
clear


host_src=${1:-"source-host"}
home_src=${2:-'~/master/'}

host_dst=${3:-"destination-host"}
home_dst=${4:-'~/dev/'}

backup_path=${5:-"vendor/"}

date=$(date "+%Y%m%d-%H%M%S")
backup_file='vendors-'$date'.tar'
home_local="${HOME}/"


printf "${color_notice_b}Prepare directory ${color_notice_h}${home_src}${backup_path}${color_notice_b} at ${color_notice_h}${host_src}${color_notice_b} host ${color_notice} \n"
ssh ${host_src} "cd "${home_src}";tar -cf "${home_src}${backup_file}" "${backup_path}
ssh ${host_dst} "rm -rf "${home_dst}${backup_path}"*"
printf "${color_off}"

printf "${color_success_b}Copy from source ${color_success_h}${host_src}${color_success_b} host to destination ${color_success_h}${host_dst}${color_success_b} host ${color_success} \n"
scp ${host_src}:${home_src}${backup_file} ${home_local}${backup_file}
scp ${home_local}${backup_file} ${host_dst}:${home_dst}${backup_file}
printf "${color_off}"

printf "${color_success_b}Extract ${color_success_h}${backup_file}${color_success_b} file to ${color_success_h}${home_dst}${backup_path}${color_success_b} path at ${color_success_h}${host_dst}${color_success_b} host ${color_success} \n"
ssh ${host_dst} "cd "${home_dst}"; tar -xf "${home_dst}${backup_file}
printf "${color_off}"

printf "${color_error_b}Cleanup${Red} \n"
ssh ${host_src} "rm "${home_src}${backup_file}
ssh ${host_dst} "rm "${home_dst}${backup_file}
rm ${home_local}${backup_file}
printf "${color_off}"
