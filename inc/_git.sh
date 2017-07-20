###############################################################
### GIT
###############################################################

function git_current {
    currentRepoURL=$(git config --get remote.origin.url)
    currentRepoWebURL=$(printf ${currentRepoURL} | sed -e 's/\(.*\)@\(.*\)\:\(.*\)\.git/http:\/\/\2\/\3/')
    currentBranchName=$(git rev-parse --abbrev-ref HEAD)
    currentCommitId=$(git rev-parse --verify HEAD)
    currentCommitMessage=$(git --no-pager log -1 --pretty=format:"%B")
    currentCommitTime=$(git --no-pager log -1 --pretty=format:"%ct")
    currentCommitAuthorName=$(git --no-pager log -1 --pretty=format:"%an" )
    currentCommitAuthorEmail=$(git --no-pager log -1 --pretty=format:"%ae" )

    printf "${InfoB}Git current commit hash is ${InfoBI}${currentCommitId}${InfoB}${Color_Off} \n"
}


function git_fetch {
    printf "${InfoB}Git fetch data from upstream ${Color_Off} \n"
    git fetch
}


function git_checkout {
    local branch=${1:-master}

    printf "${InfoB}Git checkout to ${InfoBI}${branch}${InfoB} ${Color_Off} \n"
    git checkout ${branch}
}


function git_revert_changes {
    printf "${InfoB}Git revert changes ${Color_Off} \n"
    git checkout -- .
}


function git_pull {
    local branch=${1:-master}

    git_current

    printf "${InfoB}Git pull ${InfoBI}${branch}${InfoB} branch from origin ${Color_Off} \n"
    git pull origin ${branch}
}
