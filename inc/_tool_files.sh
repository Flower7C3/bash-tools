###############################################################
### Scripts
###############################################################

function copy_scripts_to_host {
    local host=$1
    printf "${BGreen}Copy scripts to ${BIGreen}${host}${BGreen} host ${Green} \n"
    for i in "${!sourcedScriptsList[@]}"
    do
        fileInfo=(${sourcedScriptsList[$i]})
        fileNameLocal=${fileInfo[0]}
        fileNameRemote=${fileInfo[1]}
        scp ${baseDir}${fileNameLocal} ${host}:'${HOME}/'${fileNameRemote}
    done
    printf "${Color_Off}"
}

function remove_scripts_from_host {
    local host=$1
    printf "${ErrorB}Cleanup scripts on ${ErrorBI}${host}${ErrorB} host ${Error} \n"
    for i in "${!sourcedScriptsList[@]}"
    do
        fileInfo=(${sourcedScriptsList[$i]})
        fileNameRemote=${fileInfo[1]}
        ssh ${host} 'rm ${HOME}/'${fileNameRemote}
    done
    printf "${Color_Off}"
}

###############################################################
### File operations over SSH
###############################################################

function copy_file_between_hosts {
    local sourceHost=$1
    local destHost=$2
    local fileName=$3
    file_name_check "$fileName"

    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} file from ${BIGreen}${sourceHost}${BGreen} host to ${BIGreen}local${BGreen} host${Green} \n"
    scp $sourceHost:$fileName $fileName

    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} file from ${BIGreen}local${BGreen} host to ${BIGreen}${destHost}${BGreen} host${Green} \n"
    scp $fileName $destHost:$fileName
}

function remove_file_from_hosts {
    local sourceHost=$1
    local destHost=$2
    local fileName=$3
    file_name_check "$fileName"

    printf "${ErrorB}Remove ${ErrorBI}${fileName}${ErrorB} file from ${ErrorBI}${sourceHost}${ErrorB} host, ${ErrorBI}${destHost}${ErrorB} host and ${ErrorBI}local${ErrorB} host${Error} \n"
    ssh $sourceHost 'rm -rf '${fileName}''
    ssh $destHost 'rm -rf '${fileName}''
    rm -rf $fileName
}

###############################################################
### Copy / move / remove on remote host
###############################################################

function copy_file_from_host_to_local {
    local host=$1
    local remoteDataDir=$2
    local localDataDir=$3
    local fileName=$4
    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} from ${BIGreen}${host}${BGreen} host to ${BIGreen}local${BGreen} host ${Green} \n"
    mkdir -p ${localDataDir}
    scp ${host}:${remoteDataDir}${fileName} ${localDataDir}${fileName}
    printf "${Color_Off}"
}

function remove_file_from_host {
    local host=$1
    local remoteDataDir=$2
    local fileName=$3
    if [[ -n "$remoteDataDir" && -n "$fileName" ]]; then
        printf "${ErrorB}Remove ${ErrorBI}${fileName}${ErrorB} file from ${ErrorBI}${host}${ErrorB} host ${Error} \n"
        ssh ${host} 'rm '${remoteDataDir}${fileName}
        printf "${Color_Off}"
    fi
}

function move_file_from_host_to_local {
    local host=$1
    local remoteDataDir=$2
    local localDataDir=$3
    local fileName=$4
    copy_file_from_host_to_local "$host" "$remoteDataDir" "$localDataDir" "$fileName"
    remove_file_from_host "$host" "$remoteDataDir" "$fileName"
}

###############################################################
### Remove on local host
###############################################################

function remove_file_from_local {
    local localDataDir=$1
    local fileName=$2

    if [[ -n "$localDataDir" && -n "$fileName" && -f "${localDataDir}${fileName}" ]]; then
        printf "${ErrorB}Remove ${ErrorBI}${fileName}${ErrorB} file from local ${Error} \n"
        rm ${localDataDir}${fileName}
        printf "${Color_Off}"
    fi
}


function remove_dir_from_local {
    local localDataDir=$1
    local dirName=$2

    if [[ -n "$localDataDir" && -n "$dirName" && -d "${localDataDir}${dirName}" ]]; then
        printf "${ErrorB}Remove ${ErrorBI}${dirName}${ErrorB} directory from local ${Error} \n"
        rm -rf ${localDataDir}${dirName}
        printf "${Color_Off}"
    fi
}
