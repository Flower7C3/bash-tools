###############################################################
### Scripts
###############################################################

function copyScriptsToHost {
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

function removeScriptsFromHost {
    local host=$1
    printf "${BRed}Cleanup scripts on ${BIRed}${host}${BRed} host ${Red} \n"
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

function copyFileBetweenHosts {
    local sourceHost=$1
    local destHost=$2
    local fileName=$3
    fileNameCheck "$fileName"

    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} file from ${BIGreen}${sourceHost}${BGreen} host to ${BIGreen}local${BGreen} host${Green} \n"
    scp $sourceHost:$fileName $fileName

    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} file from ${BIGreen}local${BGreen} host to ${BIGreen}${destHost}${BGreen} host${Green} \n"
    scp $fileName $destHost:$fileName
}

function removeFileFromHosts {
    local sourceHost=$1
    local destHost=$2
    local fileName=$3
    fileNameCheck "$fileName"

    printf "${BRed}Remove ${BIRed}${fileName}${BRed} file from ${BIRed}${sourceHost}${BRed} host, ${BIRed}${destHost}${BRed} host and ${BIRed}local${BRed} host${Red} \n"
    ssh $sourceHost 'rm -rf '${fileName}''
    ssh $destHost 'rm -rf '${fileName}''
    rm -rf $fileName
}

###############################################################
### Copy / move / remove on remote host
###############################################################

function copyFileFromHostToLocal {
    local host=$1
    local remoteDataDir=$2
    local localDataDir=$3
    local fileName=$4
    printf "${BGreen}Copy ${BIGreen}${fileName}${BGreen} from ${BIGreen}${host}${BGreen} host to ${BIGreen}local${BGreen} host ${Green} \n"
    mkdir -p ${localDataDir}
    scp ${host}:${remoteDataDir}${fileName} ${localDataDir}${fileName}
    printf "${Color_Off}"
}

function removeFileFromHost {
    local host=$1
    local remoteDataDir=$2
    local fileName=$3
    if [[ -n "$remoteDataDir" && -n "$fileName" ]]; then
        printf "${BRed}Remove ${BIRed}${fileName}${BRed} file from ${BIRed}${host}${BRed} host ${Red} \n"
        ssh ${host} 'rm '${remoteDataDir}${fileName}
        printf "${Color_Off}"
    fi
}

function moveFileFromHostToLocal {
    local host=$1
    local remoteDataDir=$2
    local localDataDir=$3
    local fileName=$4
    copyFileFromHostToLocal "$host" "$remoteDataDir" "$localDataDir" "$fileName"
    removeFileFromHost "$host" "$remoteDataDir" "$fileName"
}

###############################################################
### Remove on local host
###############################################################

function removeFileFromLocal {
    local localDataDir=$1
    local fileName=$2

    if [[ -n "$localDataDir" && -n "$fileName" && -f "${localDataDir}${fileName}" ]]; then
        printf "${BRed}Remove ${BIRed}${fileName}${BRed} file from local ${Red} \n"
        rm ${localDataDir}${fileName}
        printf "${Color_Off}"
    fi
}
