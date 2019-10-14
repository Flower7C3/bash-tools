function ftp_upload() {
    local FTP_HOST=$1
    local FTP_USER=$2
    local FTP_PASS=$3
    local upload_path=$4
    local upload_file=$5
    if [[ -n "$upload_path" && -n "$upload_file" && -f "${upload_file}" ]]; then
        ftp -n <<EOF
open ${FTP_HOST}
user ${FTP_USER} ${FTP_PASS}
cd ${upload_path}
pwd
put ${upload_file}
EOF
    fi
}

function ftp_remove() {
    local FTP_HOST=$1
    local FTP_USER=$2
    local FTP_PASS=$3
    local upload_path=$4
    local upload_file=$5
    if [[ -n "$upload_path" && -n "$upload_file" && -f "${upload_file}" ]]; then
        ftp -n <<EOF
open ${FTP_HOST}
user ${FTP_USER} ${FTP_PASS}
cd ${upload_path}
del ${upload_file}
EOF
    fi
}
