#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../vendor/Flower7C3/bash-helpers/_base.sh"

function generate_passphrase() {
    LC_ALL=C tr -dc 'QWERTYUPADFHJKXCVNMqwertyupadfhjkxcvnm3479' </dev/urandom | head -c 32
}

## VARIABLES
_owncloud_api_url="${OWNCLOUD_API_URL}"
_owncloud_api_sharing_path="${OWNCLOUD_API_SHARING_PATH:-/ocs/v2.php/apps/files_sharing/api/v1}"
_owncloud_api_capabilities_path="${OWNCLOUD_API_CAPABILITIES_PATH:-/ocs/v1.php/cloud/capabilities?format=json}"
_owncloud_api_user="${OWNCLOUD_API_USER}"
_owncloud_api_password="${OWNCLOUD_API_PASSWORD}"
_shared_pack_passphrase="$(generate_passphrase)"

## WELCOME
program_title "Put file to OwnCloud"

index=0
prompt_variable export_zip_file_name "Export filename" "${_export_zip_file_name}" $((++index)) "$@"
remote_zip_file_name=$(basename $export_zip_file_name)

while true; do
    prompt_variable shared_resource_expire_days "Shared resource expire days" "${_shared_resource_expire_days}" $((++index)) "$@"
    if [[ -z "$(echo $shared_resource_expire_days | grep -E "\b[0-9]+\b")" ]]; then
        display_error "Invalid days value!"
    elif [[ "$shared_resource_expire_days" -lt "1" ]]; then
        display_error "Please set share days!"
    elif [[ "$shared_resource_expire_days" -gt "10" ]]; then
        display_error "Please do not share more than 10 days!"
    else
        break
    fi
done
if [[ "$OSTYPE" == "darwin"* ]]; then
    declare -r shared_resource_expire_date="$(date -v +"${shared_resource_expire_days}d" +"%Y-%m-%d")"
else
    declare -r shared_resource_expire_date="$(date -d "+${shared_resource_expire_days} days" +"%Y-%m-%d")"
fi

prompt_password shared_pack_passphrase "Shared resource passphrase" "${_shared_pack_passphrase}" $((++index)) "$@"

if [[ -z "$_owncloud_api_url" ]]; then
    prompt_variable _owncloud_api_url "OwnCloud API URL"
fi
if [[ -z "$_owncloud_api_user" ]]; then
    prompt_variable _owncloud_api_user "OwnCloud API user"
fi
if [[ -z "$_owncloud_api_password" ]]; then
    prompt_password _owncloud_api_password "OwnCloud API password"
fi

## PROGRAM
confirm_or_exit "Upload ${COLOR_QUESTION_H}${export_zip_file_name}${COLOR_QUESTION} to ${COLOR_QUESTION_H}${_owncloud_api_url}${COLOR_QUESTION} instance?"

display_info "Get ${COLOR_INFO_H}${_owncloud_api_url}${COLOR_INFO} service configuration"
response_json=$(
    curl --progress-bar -s \
        --header "OCS-APIRequest: true" \
        -u "${_owncloud_api_user}:${_owncloud_api_password}" \
        "${_owncloud_api_url}${_owncloud_api_capabilities_path}"
)
OWNCLOUD_WEBDAV_PATH='/'$(php -r 'error_reporting(0);$a=json_decode($argv[1],true);echo $a["ocs"]["data"]["capabilities"]["core"]["webdav-root"];' "${response_json}")

display_info "Share ${COLOR_INFO_H}${export_zip_file_name}${COLOR_INFO} file as ${COLOR_INFO_H}${remote_zip_file_name}${COLOR_INFO} file to ${COLOR_INFO_H}${_owncloud_api_url}${COLOR_INFO} service"
curl --progress-bar -s \
    -u "${_owncloud_api_user}:${_owncloud_api_password}" \
    -X PUT --data-binary @"${export_zip_file_name}" \
    "${_owncloud_api_url}${OWNCLOUD_WEBDAV_PATH}${remote_zip_file_name}"

display_info "$DISPLAY_LINE_PREPEND_TAB" "Update ${COLOR_INFO_H}${remote_zip_file_name}${COLOR_INFO} file persmission at ${COLOR_INFO_H}${_owncloud_api_url}${COLOR_INFO} service..."
response_json_zip=$(
    curl --progress-bar -s \
        --header "OCS-APIRequest: true" \
        -u "${_owncloud_api_user}:${_owncloud_api_password}" \
        -X POST \
        --data "expireDate=${shared_resource_expire_date}&password=${shared_pack_passphrase}&passwordChanged=false&path=${remote_zip_file_name}&permissions=19&shareType=3" \
        "${_owncloud_api_url}${_owncloud_api_sharing_path}/shares?format=json"
)
shared_zip_file_url=$(php -r 'error_reporting(0);$a=json_decode($argv[1],true);echo $a["ocs"]["data"]["url"];' "${response_json_zip}")
if [[ -n "$shared_zip_file_url" ]]; then
    display_success "$DISPLAY_LINE_PREPEND_TAB" "Shared ZIP file URL is ${shared_zip_file_url}"
else
    display_error "$DISPLAY_LINE_PREPEND_TAB" "Share failed, server response is ${COLOR_CONSOLE}${response_json_zip}"
fi
