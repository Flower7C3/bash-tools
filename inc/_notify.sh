###############################################################
### Notify
###############################################################

function slack_notify  {
    local service_identifier=$1
    local url="https://hooks.slack.com/services/${service_identifier}"
    local payload=$(echo "$2" | sed ':a;N;$!ba;s/\n//g')

    printf "${color_info_b}Send notification to Slack${color_off} \n"
    curl -X POST --data "payload=${payload}" ${url}
    echo ""
}

function slack_notify_project_updated  {
    local slack_id=$1
    local user_name=${2:-""}
    local user_icon=${3:-""}
    local channel=${4:-""}
    local project_url=${5:-""}
    local project_dir=${6:-""}

    git_current

    slack_notify "${slack_id}" '
        {
            "channel": "'"${channel}"'",
            "username": "'"${user_name}"'",
            "icon_emoji": "'"${user_icon}"'",
            "text": "
                    Aloha. Project *<'"${project_url}"'>* is now updated at *<'"${current_repo_web_url}"'/network/'"${current_branch_name}"'|'"${current_branch_name}"'>* branch from *<'"${current_repo_web_url}"'|'"${current_repo_url}"'>* repository in `'"${project_dir}"'` directory :tada:
            ",
            "attachments": [
                {
                    "fallback": "Project '"${project_url}"' updated to '"${current_commit_id}"' commit",
                    "color": "good",
                    "author_name": "'"${current_commit_author_name}"' <'"${current_commit_author_email}"'>",
                    "title": "Commit '"${current_commit_id}"'",
                    "title_link": "'"${current_repo_web_url}"'/commit/'"${current_commit_id}"'",
                    "text": "'"${current_commit_message}"'",
                    "ts": '"${current_commit_time}"'
                }
            ]
        }
        '
}

function msteams_notify {
    local service_identifier=$1
    local url="https://outlook.office.com/webhook/${service_identifier}"
    local payload=$(echo "$2" | sed ':a;N;$!ba;s/\n//g')

    printf "${color_info_b}Send notification to MS Teams${color_off} \n"
    curl -vs -X POST --data "${payload}" ${url}
    echo ""
}

function msteams_notify_project_updated {
    local team_id=$1
    local project_url=${2:-""}
    local project_host_dir=${3:-"`whoami`@`hostname`"}
    local theme_color=${4:-"000000"}

    git_current

    msteams_notify "${team_id}" '
        {
            "@context": "http://schema.org/extensions",
            "@type": "MessageCard",
            "themeColor": "'"${theme_color}"'",
            "title": "'"${project_host_dir}"'",
            "text": "Aloha. Project **<'"${project_url}"'>** is now updated at **'"${current_branch_name}"'** branch from **'"${current_repo_url}"'** repository :)",
            "sections": [
                {
                    "startGroup": true,
                    "activityImage": "'"${current_commit_author_gravatar}"'",
                    "activityTitle": "'"${current_commit_author_name}"' <'"${current_commit_author_email}"'>",
                    "activitySubtitle": "'"${current_commit_datetime}"'",
                    "facts": [
                        {
                            "name": "Repository",
                            "value": "'"${current_repo_url}"'"
                        },
                        {
                            "name": "Branch",
                            "value": "'"${current_branch_name}"'"
                        },
                        {
                            "name": "Commit",
                            "value": "'"${current_commit_id:0:8}"'"
                        }
                    ],
                    "text": "'"${current_commit_message}"'",
                    "potentialAction": [
                        {
                            "@type": "OpenUri",
                            "name": "View repo",
                            "targets": [
                                { "os": "default", "uri": "'"${current_repo_web_url}"'" }
                            ]
                        },
                        {
                            "@type": "OpenUri",
                            "name": "View branch",
                            "targets": [
                                { "os": "default", "uri": "'"${current_repo_web_url}"'/network/'"${current_branch_name}"'" }
                            ]
                        },
                        {
                            "@type": "OpenUri",
                            "name": "View commit",
                            "targets": [
                                { "os": "default", "uri": "'"${current_repo_web_url}"'/commit/'"${current_commit_id}"'" }
                            ]
                        }
                    ]
                }
            ]
        }
        '
}
