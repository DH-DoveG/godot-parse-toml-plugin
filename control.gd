extends Control




func _ready() -> void:
	
	# 数字测试
	#GTomlParse.parse_file("res://toml_file/test_number.toml")
	
	# i64
	#print( 9223372036854775807 )
	
	# 字符串测试
	#GTomlParse.parse_file("res://toml_file/test_string.toml")
	
	# 数组测试
	#GTomlParse.parse_file("res://toml_file/test_array.toml")
	
	# 字典测试
	#GTomlParseTool.parse_file( "res://toml_file/test_dictionary.toml" )
	
	# 时间测试
	GTomlParseTool.parse_file( "res://toml_file/test_time.toml" )
	
	#"Hello \\World"
	
	#var rex = RegEx.new()
	#rex.compile( "^(?P<year>\\d{4})-(?P<month>0[1-9]|1[012])-(?P<day>0[1-9]|[12][0-9]|3[01])([Tt]|[ \\t]+)(?P<hour>[01][0-9]|2[0-3]):(?P<minute>[0-5][0-9]):(?P<second>[0-5][0-9])(\\.(?P<fraction>[0-9]+))?(Z|[+-][01][0-9]:?[0-5][0-9])?$" )
	
	#var res = rex.search( "2022-10-31T10:30:45Z" )
	
	#print(rex.get_pattern())
	
	# 获取时间的分组信息
	#print( res.strings )
	
	# 获取匹配的名字，key 为名，value 为在 string 中的位置，可以组合一下
	#print( res.names )
	pass
	
