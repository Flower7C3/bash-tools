base_dir_path=$(dirname ${BASH_SOURCE})/

sourced_scripts_list=(
	'inc/_base_for_remote.sh	_base.sh'
	'inc/_colors.sh				_inc_colors.sh'
	'inc/_io.sh					_inc_io.sh'
	'inc/_tool_files.sh			_inc_tool_files.sh'
	'inc/_tool_check.sh			_inc_tool_check.sh'
	'inc/_tool_vendor.sh		_inc_tool_vendor.sh'
	'inc/_tool_sql.sh			_inc_tool_sql.sh'
	'inc/_notify.sh			    _inc_notify.sh'
	'inc/_git.sh			    _inc_git.sh'
	'inc/_www.sh			    _inc_www.sh'
)

for i in "${!sourced_scripts_list[@]}";
do
	if [[ "$i" > 0 ]];
	then
		file_info=(${sourced_scripts_list[$i]})
	    local_file_name=${file_info[0]}
		source ${base_dir_path}${local_file_name}
	fi
done
