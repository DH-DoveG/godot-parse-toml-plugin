
#===========================================
# 介绍：对 DHTomlTokenObject 进行解析
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name DHTomlValue
extends Node




# toml 解析组建
var toml_dictionary		: DHTomlParseDictionary = null
var toml_numbar			: DHTomlParseNumber = null
var toml_string			: DHTomlParseString = null
var toml_array			: DHTomlParseArray = null
var toml_time			: DHTomlParseTime = null




func _init() -> void:
	
	# 实例化组建各个解析组建
	toml_dictionary	= DHTomlParseDictionary.new()
	toml_numbar		= DHTomlParseNumber.new()
	toml_string		= DHTomlParseString.new()
	toml_array		= DHTomlParseArray.new()
	toml_time		= DHTomlParseTime.new()




# 解析 token 将 token 转换为实际表示的值
# 在完成这一段解析后即可对这些值进行合并操作了
func parse(_token: DHTomlTokenObject) -> DHTomlTokenObject:
	
	match _token.type:
		
		
		DHTomlTokenObject.TOKEN_TYPE.NULL:
			
			assert(false, "null 类型的 token 无法解析")
		
		
		DHTomlTokenObject.TOKEN_TYPE.LIST:
			
			_token = _list_type(_token)
		
		
		DHTomlTokenObject.TOKEN_TYPE.ARRAY:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _array_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.OTHER:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _other_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.DICTIONARY:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _dictionary_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.STRING_SINGLEQUOTE:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _string_singlequotes_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.STRING_DOUBLEQUOTATION:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _string_doublequotation_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_SINGLEQUOTE:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _multiline_string_singlequotes_type(_token.original_value)
		
		
		DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_DOUBLEQUOTATION:
			
			_token.parse_key = _parse_key(_token.original_key)
			_token.parse_value = _multiline_string_doublequotation_type(_token.original_value)
	
	#print("token-key > ", _token.parse_key, " || token-value > ", _token.parse_value)
	
	return _token



#
func _array_type(_value: String) -> Array:
	
	var result: Array = []
	
	result = toml_array.parse(_value)
	
	# 将值进行解析并替换
	for item in range(0, result.size()):
		
		if typeof(result[item]) == TYPE_ARRAY:
			
			result[item] = _parse_recursion(result[item])
		
		else:
			
			result[item] = _auto_type(result[item])
		# 如果字符串由 """ 开头就交给多行解析
	
	return result




# 递归解析
func _parse_recursion(_value: Variant) -> Variant:
	
	# 如果值是 数组类型
	if typeof(_value) == TYPE_ARRAY:
		
		# 遍历数组
		for item in range(0, _value.size()):
			
			# 如果还是数组类型就递归，并替换掉当前的 value
			if typeof(_value[item]) == TYPE_ARRAY:
				
				_value[item] = _parse_recursion(_value[item])
			
			# 如果不是数组类型就解析，并替换掉当前的 value
			else:
				
				_value[item] = _auto_type(_value[item])
	
	# 如果值是 字典类型
	elif typeof(_value) == TYPE_DICTIONARY:
		
		# 遍历
		for item in range(0, _value.size()):
			
			# 如果还是字典类型就递归，并替换掉当前的 vlaue
			if typeof(_value[item]) == TYPE_DICTIONARY:
				
				_value[item] = _parse_recursion(_value[item])
			
			# 如果不是字典就解析，并替换掉当前的 value
			else:
				
				_value[item] = _auto_type(_value[item])
	
	# 返回解析替换完成的 _value
	return _value




# 自动推导并解析类型
func _auto_type(_value: String) -> Variant:
	
	#print("type auto >", _value, "<")
	
	if _value.begins_with('"""'):
			
		return _multiline_string_doublequotation_type(_value)
	
	elif _value.begins_with("'''"):
		
		return _multiline_string_singlequotes_type(_value)
	
	elif _value.begins_with('"'):
		
		return _string_doublequotation_type(_value)
	
	elif _value.begins_with("'"):
		
		return _string_singlequotes_type(_value)
	
	elif _value.begins_with("{"):
		
		return _dictionary_type(_value)
	
	elif _value.begins_with("["):
		
		return _array_type(_value)
	
	else:
		
		var result = _other_type(_value)
		
		assert(result != null, "无法解析的值")
		
		return result
	
	return null




# other 类型
# 遇到 other 类型
# 首先就排除掉一定范围的值了
# 数字 or 时间
# 只有可能是这两种，如果不是就报错
func _other_type(_value: String) -> Variant:
	
	var result: Variant = null
	
	_value = _value.strip_edges()
	
	# 尝试解析为数字
	result = toml_numbar.parse(_value)
	
	if result != null:
		
		return result
	
	# 尝试解析为时间
	result = toml_time.parse(_value)
	
	if result != null:
		
		return result
	
	assert(result, "未知的值")
	
	return null




# 字典的处理
func _dictionary_type(_value: String) -> Dictionary:
	
	var result: Dictionary = {}
	
	# 获取初步的处理
	result = toml_dictionary.parse_value(_value)
	
	var new: Dictionary = {}
	# 进行深层次的解析
	# 将值进行解析并替换
	for item in result:
		
		# 如果 key 是数组,就解析 value
		if typeof(item) == TYPE_PACKED_STRING_ARRAY:
			
			result[item] = _auto_type(result[item])
		
		# 如果 key 不是 [] 就解析key 将 key 变成 []
		if typeof(item) != TYPE_PACKED_STRING_ARRAY:
			
			var new_key = _parse_key(item)
			
			# 判断 key 是否重复
			#print("new_key | ", new_key)
			assert(new.get(new_key) == null, "key 重复")
			
			new[new_key] = _auto_type(result[item])
	
	# 调整 dic
	result = toml_dictionary.adjust(new)
	
	return result




# 单引号字符串的处理
func _string_singlequotes_type(_value: String) -> String:
	
	return toml_string.parse_singlequotes(_value)




# 双引号字符串的处理
func _string_doublequotation_type(_value: String) -> String:
	
	return toml_string.parse_doublequotation(_value)




# # 双引号多行字符串的处理
func _multiline_string_doublequotation_type(_value: String) -> String:
	
	return toml_string.parse_multiline_doublequotation(_value)




# 单引号多行字符串的处理
func _multiline_string_singlequotes_type(_value: String) -> String:
	
	return toml_string.parse_multiline_singlequotes(_value)




# 表的处理
# [list] - [list] - [[list]] - [l.i.s.t]
func _list_type(_token: DHTomlTokenObject) -> DHTomlTokenObject:
	
	# 初步去除两边的 []
	var list: String = _token.original_value.substr(1, _token.original_value.length() - 2)
	
	# 去掉两边多余转义字符
	list = list.strip_edges()
	
	# 如果两边还是 [] 就视为表数组并去掉两边
	if list.begins_with("[") and list.ends_with("]"):
		
		_token.is_list_array = true
		list = list.substr(1, list.length() - 2).strip_edges()
	
	var key: PackedStringArray = _parse_key(list)
	
	# 判断是否是空
	assert(not key.is_empty(), "空key，错误")
	
	# 判断 key 是否合法
	# 如果是表数组的话， key 应该只有 1 个
	# [[bin]] T
	# [[bin.o]] F
	if _token.is_list_array:
		
		#print("key ||", key)
		
		assert(key.size() == 1, "表数组错误")
	
	# 解析 key 并设置新 key
	_token.parse_key =  _parse_key(list)
	
	return _token




# 解析 key 值
func _parse_key(_key: String) -> PackedStringArray:
	
	var new: Array = []
	var reg: RegEx = RegEx.new()
	
	reg.compile("^[A-Za-z0-9_-]+$")
	
	var key: String = ""
	
	# 遍历 loads
	for item in toml_dictionary.parse_key(_key):
		
		key = item.strip_edges()
		
		if key.begins_with("'"):
			
			new.append(_string_singlequotes_type(key))
		
		elif key.begins_with('"'):
			
			new.append(_string_doublequotation_type(key))
		
		else:
			
			assert(reg.search(key) != null, "key 解析错误")
			new.append(key)
	
	return new

