###############################################################
### GIT
###############################################################

function email_to_hash {
    printf $1 | tr '[A-Z]' '[a-z]' | md5
}

function gravatar_url {
    local email=$1
    local size=${2:-'256'}
    local fallback=${3:-'identicon'}
    local HASH=$(email_to_hash ${email})
    local URL="http://www.gravatar.com/avatar/${HASH}?s=${size}&d=${fallback}"
    printf $URL
}

function git_current {
    current_repo_url=$(git config --get remote.origin.url)
    current_repo_web_url=$(printf ${current_repo_url} | sed -e 's/\(.*\)@\(.*\)\:\(.*\)\.git/http:\/\/\2\/\3/')
    current_branch_name=$(git rev-parse --abbrev-ref HEAD)
    current_commit_id=$(git rev-parse --verify HEAD)
    current_commit_message=$(git --no-pager log -1 --pretty=format:"%B")
    current_commit_time=$(git --no-pager log -1 --pretty=format:"%ct")
    current_commit_datetime=$(git --no-pager log -1 --pretty='format:%cd' --date=format:'%Y-%m-%d %H:%M:%S')
    current_commit_author_name=$(git --no-pager log -1 --pretty=format:"%an" )
    current_commit_author_email=$(git --no-pager log -1 --pretty=format:"%ae" )
    current_commit_author_gravatar=$(gravatar_url ${current_commit_author_email} 40)

    printf "${color_info_b}Git current commit hash is ${color_info_h}${current_commit_id}${color_info_b}${color_off} \n"
}


function git_fetch {
    printf "${color_info_b}Git fetch data from upstream ${color_off} \n"
    git fetch
}


function git_checkout {
    local branch=${1:-master}

    printf "${color_info_b}Git checkout to ${color_info_h}${branch}${color_info_b} ${color_off} \n"
    git checkout ${branch}
}


function git_revert_changes {
    printf "${color_info_b}Git revert changes ${color_off} \n"
    git checkout -- .
}


function git_pull {
    local branch=${1:-master}

    git_current

    printf "${color_info_b}Git pull ${color_info_h}${branch}${color_info_b} branch from origin ${color_off} \n"
    git pull origin ${branch}
}
