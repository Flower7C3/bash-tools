base_dir_path=$(dirname ${BASH_SOURCE})/

sourced_scripts_list=(
    '_base.sh					_base.sh'
    '_inc_colors.sh				_inc_colors.sh'
    '_inc_io.sh					_inc_io.sh'
    '_inc_tool_files.sh			_inc_tool_files.sh'
    '_inc_tool_check.sh			_inc_tool_check.sh'
    '_inc_tool_vendor.sh		_inc_tool_vendor.sh'
    '_inc_tool_sql.sh			_inc_tool_sql.sh'
    '_inc_notify.sh			    _inc_notify.sh'
    '_inc_git.sh			    _inc_git.sh'
    '_inc_www.sh			    _inc_www.sh'
    '_inc_s3.sh			        _inc_s3.sh'
    '_inc_ftp.sh			    _inc_ftp.sh'
)

for i in "${!sourced_scripts_list[@]}"; do
    if [[ "$i" > 0 ]]; then
        file_info=(${sourced_scripts_list[$i]})
        local_file_name=${file_info[0]}
        source ${base_dir_path}${local_file_name}
    fi
done
