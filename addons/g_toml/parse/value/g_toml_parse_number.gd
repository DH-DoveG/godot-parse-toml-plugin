
#===========================================
# 介绍：用于解析数字
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name GTomlParseNumber
extends Node




# 正则表达式实例
var regex: RegEx = null
# 存放正则表达式
var pattern: String = ""




func _init() -> void:
	
	regex = RegEx.new()




# 解析值，尝试解析为数字
func parse( _value: String ) -> Variant:
	
	regex.clear()
	
	var inf_nan: Variant = _is_inf_or_nan( _value )
	
	if inf_nan != null:
		
		return inf_nan
	
	# 说起来 toml 是支持 100_000 这种东西的，先将 _ 去掉
	_value = _value.replace( "_", "" )
	
	# 二进制
	if _is_bin( _value ):
		
		return _value.bin_to_int()
	
	# 八进制
	elif _is_octal( _value ):
		
		var num		: int = _value.substr(2).to_int()
		var decimal	: int = 0
		var base	: int = 1
		
		while( num > 0 ):
			
			var lastDigit: int = num % 10
			num = num / 10
			decimal += lastDigit * base
			base *= 8
		
		return decimal
	
	# 十六进制
	elif _is_hexadecimal( _value ):
		
		return _value.hex_to_int()
	
	# 浮点
	elif _is_float( _value ):
		
		return _value.to_float()
	
	# 整数
	elif _value.is_valid_int():
		
		return _value.to_int()
	
	# 科学计数法如：1.2e1
	elif _is_scientific_counting( _value ):
		
		return _value
	
	# 无法转换为数字就返回 null
	return null




# 判断字符串是否是无穷或者不是数
func _is_inf_or_nan( _value: String ) -> Variant:
	
	pattern = "^[+-]?(inf|nan)$"
	
	regex.compile(pattern)
	
	var res: RegExMatch = regex.search( _value )
	
	if res:
		
		match res.get_string():
			
			"+inf", "inf":
				
				return INF
			
			"-inf":
				
				return -INF
			
			"+nan", "nan":
				
				return NAN
			
			"-nan":
				
				return -NAN
	
	return null




# 判断字符串是否是二进制
func _is_bin( _value: String ) -> bool:
	
	pattern = "^0b[01]+(_[01]+)*$"
	
	regex.compile( pattern )
	
	return regex.search( _value ) != null




# 判断字符串是否是八进制
func _is_octal( _value: String ) -> bool:
	
	pattern = "^0o[0-7]+(_[0-7]+)*$"
	
	regex.compile( pattern )
	
	return regex.search( _value ) != null




# 判断是否浮点
func _is_float( _value: String ) -> bool:
	
	pattern = "^[+-]?(0|[1-9][0-9]*(_[0-9]+)*)\\.[0-9]+(_[0-9]+)*$"
	
	regex.compile( pattern )
	
	return regex.search( _value ) != null




# 判断字符串是否是十六进制
func _is_hexadecimal( _value: String ) -> bool:
	
	pattern = "^0x[0-9A-Fa-f]+(_[0-9A-Fa-f]+)*$"
	
	regex.compile( pattern )
	
	return regex.search( _value ) != null




# 判断字符串是不是科学计数法表示的
func _is_scientific_counting( _value: String ) -> bool:
	
	pattern = "^[+-]?(0|[1-9][0-9]*(_[0-9]+)*)(\\.[0-9]+(_[0-9]+)*)?[eE][+-]?[0-9]+(_[0-9]+)*$"
	
	regex.compile( pattern )
	
	return regex.search( _value ) != null
