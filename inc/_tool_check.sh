###############################################################
### File check
###############################################################
function fileNameCheck {
    local fileName=$1
    if [ -z "$fileName" ]; then
        displayError "File name not specified!"
        programError
    fi
    fileNameTest=$(printf $fileName | egrep "/")
    if [ -n "$fileNameTest" ]; then
        displayError "File name is wrong!"
        programError
    fi
}

function dirNameCheck {
    local dirName=$1
    if [ -z "$dirName" ]; then
        displayError "Dir name not specified!"
        programError
    fi
    outputDirTest1=$(printf $dirName | egrep "/$")
    if [ -z "$outputDirTest1" ]; then
        displayError "Dir name must end with slash!"
        programError
    fi
}

###############################################################
### Domain check
###############################################################
function checkSSH {
    local username=$1
    local hostname=$2
    sshStatus=$(ssh -i /etc/projects/id_rsa -l ${username} ${hostname} "pwd")
    printf "${InfoB}%16s ${InfoBI}%60s${InfoB}\t${LogBI}%s${InfoB}\n${Log}" "SSH" "${username}@${hostname}" "$sshStatus"
}

function checkDomain {
    local domain=$1
    local userpass=${2:-"vml:vml"}
    local statusCode=$(curl -H "Cache-Control: no-cache" -L -u "${userpass}" -s -o /dev/null -I -w "%{http_code}" ${domain})
    printf "${InfoB}%16s ${InfoBI}%60s${InfoB}\t" "DOMENA" "$domain"
    if (( "$statusCode" >= 200 && "$statusCode" < 400 )); then
        printf "${SuccessBI}"
    else
        if (( "$statusCode" >= 400 && "$statusCode" < 600 )); then
            printf "${ErrorBI}"
        else
            printf "${LogBI}"
        fi
    fi
    printf "%s\n${Log}" $statusCode
}
