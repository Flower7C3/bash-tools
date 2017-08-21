function s3_upload {
    aws_profile=$1
    aws_bucket=$2
    local_path=$3
    aws_path=$4
    if [[ -n "$aws_profile" ]] && [[ -n "$aws_bucket" ]] && [[ -n "$aws_path" ]] && [[ -n "$local_path" ]]; then
        dry_run=${5:-"y"}
        if [[ "$dry_run" == "y" ]]; then
            aws s3 cp --dryrun --profile "$aws_profile" "$local_path" "s3://${aws_bucket}/${aws_path}" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
        else
            aws s3 cp --profile "$aws_profile" "$local_path" "s3://${aws_bucket}/${aws_path}" --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers
        fi
    else
        display_error "S3 upload fail: specify all required parameters!"
    fi
}

function s3_download {
    aws_profile=$1
    aws_bucket=$2
    aws_path=$3
    local_path=$4
    if [[ -n "$aws_profile" ]] && [[ -n "$aws_bucket" ]] && [[ -n "$aws_path" ]] && [[ -n "$local_path" ]]; then
        dry_run=${5:-"y"}
        if [[ "$dry_run" == "y" ]]; then
            aws s3 cp --dryrun --profile "$aws_profile" "s3://${aws_bucket}/${aws_path}" "$local_path"
        else
            aws s3 cp --profile "$aws_profile" "s3://${aws_bucket}/${aws_path}" "$local_path"
        fi
    else
    display_error "S3 download fail: specify all required parameters!"
    fi
}

function s3_remove {
    aws_profile=$1
    aws_bucket=$2
    aws_path=$3
    if [[ -n "$aws_profile" ]] && [[ -n "$aws_bucket" ]] && [[ -n "$aws_path" ]]; then
        dry_run=${4:-"y"}
        if [[ "$dry_run" == "y" ]]; then
            aws s3 rm --dryrun --profile "$aws_profile" "s3://${aws_bucket}/${aws_path}"
        else
            aws s3 rm --profile "$aws_profile" "s3://${aws_bucket}/${aws_path}"
        fi
    else
        display_error "S3 remove fail: specify all required parameters!"
    fi
}
