
#===========================================
# 介绍：用于解析时间
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name GTomlParseTime
extends Node




# 正则表达式实例与正则表达式
var regex: RegEx = null

var pattern: String = "^(?P<year>\\d{4})-(?P<month>0[1-9]|1[012])-(?P<day>0[1-9]|[12][0-9]|3[01])([Tt]|[ \\t]+)(?P<hour>[01][0-9]|2[0-3]):(?P<minute>[0-5][0-9]):(?P<second>[0-5][0-9])(\\.(?P<microsecond>[0-9]+))?(Z|[+-][01][0-9]:?[0-5][0-9])?$"




func _init() -> void:
	
	regex = RegEx.new()
	regex.compile( pattern )




#
func parse( _value: String ) -> GTomlTimeObject:
	
	var time: GTomlTimeObject = null
	
	var rem: RegExMatch = regex.search( _value )
	
	# 如果匹配成功就返回一个 GTomlTimeObject 实例
	if rem != null:
		
		time = GTomlTimeObject.new()
		
		time.time_set( rem.names, rem.strings )
	
	return time
