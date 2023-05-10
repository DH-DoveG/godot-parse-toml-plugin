
#===========================================
# 介绍：GTomlTimeObject 类
#      由存放 时间类型 的 token 生成
# 
# 
# 作者：DH-DoveG
#===========================================

class_name GTomlTimeObject
extends Node




#2022-10-31 10:30:45.123456Z
#这个时间是2022年10月31日上午10点30分45.123456秒，Z表示这是协调世界时（UTC）。
#
#具体解释如下：
#
#- 2022：年份，表示这个时间发生在2022年。
#- 10：月份，表示这个时间发生在10月。
#- 31：日期，表示这个时间发生在31日。
#- 10：小时，表示这个时间发生在上午10点。
#- 30：分钟，表示这个时间发生在10点30分。
#- 45：秒钟，表示这个时间发生在10点30分45秒。
#- 123456：微秒，表示这个时间发生在45秒的123456微秒处。
#- Z：时区，表示这个时间是协调世界时（UTC），也称为格林威治标准时间（GMT）。
#
#总之，这个时间精确到了微秒级别，而且使用了标准化的协调世界时。

# 年
var year		: String = ""
# 月
var month		: String = ""
# 日
var day			: String = ""
# 时
var hour		: String = ""
# 分
var minute		: String = ""
# 秒
var second		: String = ""
# 微秒 ?
var microsecond	: String = ""
# 时区
var timezone	: String = ""




# 设置时间
func time_set( _time_names: Dictionary, _time_values: PackedStringArray ) -> void:
	
	#print( "_time_names  >", _time_names )
	#print( "_time_values >", _time_values )
	
	for key in _time_names:
		
		# names的 value 对应 values 的下标
		# 保存转换为 int 的时间
		set( key, _time_values[ _time_names[ key ] ] )
	
	# 时区
	timezone = _time_values[ 10 ]
