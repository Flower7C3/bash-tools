#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"
clear

host_src=${1:-"source-host"}
home_src=${2:-'~/master/'}

host_dst=${3:-"destination-host"}
home_dst=${4:-'~/dev/'}

backup_path=${5:-"vendor/"}

date=$(date "+%Y%m%d-%H%M%S")
backup_file='vendors-'$date'.tar'
home_local="${HOME}/"

printf "${COLOR_NOTICE_B}Prepare directory ${COLOR_NOTICE_H}${home_src}${backup_path}${COLOR_NOTICE_B} at ${COLOR_NOTICE_H}${host_src}${COLOR_NOTICE_B} host ${COLOR_NOTICE} \n"
ssh ${host_src} "cd "${home_src}";tar -cf "${home_src}${backup_file}" "${backup_path}
ssh ${host_dst} "rm -rf "${home_dst}${backup_path}"*"
color_reset

printf "${COLOR_SUCCESS_B}Copy from source ${COLOR_SUCCESS_H}${host_src}${COLOR_SUCCESS_B} host to destination ${COLOR_SUCCESS_H}${host_dst}${COLOR_SUCCESS_B} host ${COLOR_SUCCESS} \n"
scp ${host_src}:${home_src}${backup_file} ${home_local}${backup_file}
scp ${home_local}${backup_file} ${host_dst}:${home_dst}${backup_file}
color_reset

printf "${COLOR_SUCCESS_B}Extract ${COLOR_SUCCESS_H}${backup_file}${COLOR_SUCCESS_B} file to ${COLOR_SUCCESS_H}${home_dst}${backup_path}${COLOR_SUCCESS_B} path at ${COLOR_SUCCESS_H}${host_dst}${COLOR_SUCCESS_B} host ${COLOR_SUCCESS} \n"
ssh ${host_dst} "cd "${home_dst}"; tar -xf "${home_dst}${backup_file}
color_reset

printf "${COLOR_ERROR_B}Cleanup${COLOR_RED} \n"
ssh ${host_src} "rm "${home_src}${backup_file}
ssh ${host_dst} "rm "${home_dst}${backup_file}
rm ${home_local}${backup_file}
color_reset
