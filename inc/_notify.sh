###############################################################
### Notify
###############################################################

function slackNotify  {
    local service_identifier=$1
    local url="https://hooks.slack.com/services/${service_identifier}"
    local payload=$(echo "$2" | sed ':a;N;$!ba;s/\n//g')

    printf "${InfoB}Send notification to Slack${Color_Off} \n"
    curl -X POST --data "payload=${payload}" ${url}
    echo ""
}

function slackNotifyProjectUpdated  {
    local slackId=$1
    local username=${2:-""}
    local usericon=${3:-""}
    local channel=${4:-""}
    local projectUrl=${5:-""}

    git_current

    slackNotify "${slackId}" '
        {
            "channel": "'"${channel}"'",
            "username": "'"${username}"'",
            "icon_emoji": "'"${usericon}"'",
            "text": "
                    Aloha. Project *<'"${projectUrl}"'>* is now updated at *<'"${currentRepoWebURL}"'/network/'"${currentBranchName}"'|'"${currentBranchName}"'>* branch from *<'"${currentRepoWebURL}"'|'"${currentRepoURL}"'>* repository in `'"${symfonyRootDir}"'` directory :tada:
            ",
            "attachments": [
                {
                    "fallback": "Project '"${projectUrl}"' updated to '"${currentCommitId}"' commit",
                    "color": "good",
                    "author_name": "'"${currentCommitAuthorName}"' <'"${currentCommitAuthorEmail}"'>",
                    "title": "Commit '"${currentCommitId}"'",
                    "title_link": "'"${currentRepoWebURL}"'/commit/'"${currentCommitId}"'",
                    "text": "'"${currentCommitMessage}"'",
                    "ts": '"${currentCommitTime}"'
                }
            ]
        }
        '
}
