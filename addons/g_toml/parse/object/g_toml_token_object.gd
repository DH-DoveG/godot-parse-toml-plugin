
#===========================================
# 介绍：用于存放 token 信息
# 
# 
# 
# 作者：DH_DoveG
#===========================================

class_name GTomlTokenObject
extends Node




# Token 类型
enum TOKEN_TYPE {
	
	# 空
	NULL,
	
	# 列表
	LIST,
	
	# 没有辨明的类型
	OTHER,
	
	# 单引号字符串类型
	STRING_SINGLEQUOTE,
	
	# 双引号字符串类型
	STRING_DOUBLEQUOTATION,
	
	# 单引号的多行字符串类型
	MULTILINE_STRING_SINGLEQUOTE,
	
	# 双引号的多行字符串类型
	MULTILINE_STRING_DOUBLEQUOTATION,
	
	# 字典
	DICTIONARY,
	
	# 数组
	ARRAY
	
}




# 类型
var type: TOKEN_TYPE = TOKEN_TYPE.NULL

# 行号
var line: int = -1

# 原始值 key 与 value
var original_key	: String = ""
var original_value	: String = ""

# 解析得到的 key 与 value
var parse_key	: PackedStringArray = []
var parse_value	: Variant = null

# LIST 用的
# 看看是不是表数组
# [[bin]] -> 这是表数组
var is_list_array: bool = false
