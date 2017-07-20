baseDir=`dirname ${BASH_SOURCE}`/

sourcedScriptsList=(
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
