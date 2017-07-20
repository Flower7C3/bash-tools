###############################################################
### File check
###############################################################
function file_name_check {
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

function dir_name_check {
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
function ssh_check {
    local username=$1
    local hostname=$2
    local keyfile=$3
    sshStatus=$(ssh -i ${keyfile} -l ${username} ${hostname} "pwd")
    printf "${InfoB}%16s ${InfoBI}%60s${InfoB}\t${LogBI}%s${InfoB}\n${Log}" "SSH" "${username}@${hostname}" "$sshStatus"
}

function domain_status_code_check {
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

function domain_status_code_check_or_rollback {
    local url=${1:-http://localhost/}

    local exists=$(curl -k -s --head ${url}  | head -n 1 | grep "HTTP/1.[01] [23]..")

    if [ "$exists" == "" ]; then

        printf "${ErrorB}Site url ${ErrorBI}${url}${ErrorB} is not working."
        if [[ "$currentCommitId" != "" ]]; then
            printf "${Info}Check ${InfoU}${InfoB}a${Info}gain or ${InfoU}r${Info}ollback or ${InfoU}s${Info}kip? \n"
        else
            printf "${Info}Check ${InfoU}${InfoB}a${Info}gain or ${InfoU}s${Info}kip? \n"
        fi
        printf "${NoticeB} > ${Notice}"
        read -e input

        if [[ "$input" != "s" ]]; then
            if [[ "$currentCommitId" != "" ]]; then
                if [[ "$input" == "r" ]]; then
                    git_checkout ${currentCommitId}
                else
                    domain_status_code_check ${url}
                fi
            else
                domain_status_code_check ${url}
            fi
        fi

    else
        printf "${SuccessB}Site url ${SuccessBI}${url}${SuccessB} is working ${Success} \n"
    fi
}
