if [[ "$BASH_VERSION" == 0* ]] || [[ "$BASH_VERSION" == 1* ]] || [[ "$BASH_VERSION" == 2* ]] || [[ "$BASH_VERSION" == 3* ]]; then
    echo "Bash version is to low. Consider upgrading to bash newer than $BASH_VERSION".
    if uname | grep -iq Darwin; then
        echo "Read more on https://itnext.io/upgrading-bash-on-macos-7138bd1066ba"
    fi
    exit 9
fi

base_dir_path=$(dirname ${BASH_SOURCE})/

sourced_scripts_list=(
    '_base_for_remote.sh    _base.sh'
    '_colors.sh             _inc_colors.sh'
    '_io.sh                 _inc_io.sh'
    '_tool_files.sh         _inc_tool_files.sh'
    '_tool_check.sh         _inc_tool_check.sh'
    '_tool_vendor.sh        _inc_tool_vendor.sh'
    '_tool_sql.sh           _inc_tool_sql.sh'
    '_notify.sh             _inc_notify.sh'
    '_git.sh                _inc_git.sh'
    '_www.sh                _inc_www.sh'
    '_ftp.sh                _inc_ftp.sh'
    '_s3.sh                 _inc_s3.sh'
)

for i in "${!sourced_scripts_list[@]}"; do
    if [[ "$i" > 0 ]]; then
        file_info=(${sourced_scripts_list[$i]})
        local_file_name=${file_info[0]}
        source "${base_dir_path}${local_file_name}"
    fi
done
