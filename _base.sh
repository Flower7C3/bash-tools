baseDir=`dirname ${BASH_SOURCE}`/

sourcedScriptsList=(
	'inc/_base_for_remote.sh	_base.sh'
	'inc/_colors.sh				_inc_colors.sh'
	'inc/_io.sh					_inc_io.sh'
	'inc/_tool_files.sh			_inc_tool_files.sh'
	'inc/_tool_check.sh			_inc_tool_check.sh'
	'inc/_tool_vendor.sh		_inc_tool_vendor.sh'
	'inc/_tool_sql.sh			_inc_tool_sql.sh'
)

for i in "${!sourcedScriptsList[@]}";
do
	if [[ "$i" > 0 ]];
	then
		fileInfo=(${sourcedScriptsList[$i]})
	    fileNameLocal=${fileInfo[0]}
		source ${baseDir}${fileNameLocal}
	fi
done
