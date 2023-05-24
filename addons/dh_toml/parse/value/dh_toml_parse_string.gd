
#===========================================
# 介绍：用于解析字符串
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name DHTomlParseString
extends Node




# 解析 双引号单行
# 值设先都是已经处理好两边的
# 即：
func parse_doublequotation(_value: String) -> String:
	
	# 去掉两边的 "
	var value: String = _value.substr(1, _value.length() - 2)
	
	return _check_doublequotation(value)




# 解析 双引号多行
func parse_multiline_doublequotation(_value: String) -> String:
	
	# 去掉前端的 """
	var value: String = _value.substr(3)
	
	# 看一下是 """ 结尾还是 "" 结尾
	if value.ends_with('"""'):
		
		value = value.substr(0, value.length() - 3)
	
	elif value.ends_with('""'):
		
		value = value.substr(0, value.length() - 2)
	
	return _check_multiline_doublequotation(value)




# 解析 单引号单行
# 单引号表示原始字面量
# 不需要处理字符串中的手动转义
# 只需要把两边的单引号截取一下就可以了
func parse_singlequotes(_value: String) -> Variant:
	
	return _value.substr(1, _value.length() - 2)




# 解析 单引号多行
func parse_multiline_singlequotes(_value: String) -> String:
	
	if _value.ends_with("'''"):
		
		return _value.substr(3, _value.length() - 6)
	
	return _value.substr(3, _value.length() - 5)




# 检查 单行字符串 是否合法
# 并将合法的手动进行转换
#\b         - backspace       (U+0008)
#\t         - tab             (U+0009)
#\n         - linefeed        (U+000A)
#\f         - form feed       (U+000C)
#\r         - carriage return (U+000D)
#\"         - quote           (U+0022)
#\\         - backslash       (U+005C)
# 上面这些需要Unicode需要转换
# 其余不需要
# 需要保证 \u 接下来的至少有 4 个 0-9 字符
# 前4个需要的保证是 0-9 a-e 之间的字符
# 后4个需要是 0-9 a-z A-Z 之间的字符
# 如果前4个不够就报错
#  a-z A-Z 字符
# TODO
func _check_doublequotation(_value: String) -> String:
	
	var result: String = ""
	
	# 主要是判断 手动 转义是否合法
	# 在遍历到 \\ 时做一个标记
	# 将手动转义转换: \\n -> \n
	var pos: int = -1
	
	# 判断是否 \u
	var is_unicod: bool = false
	var cache_unicod: String = ""
	var reg: RegEx = RegEx.new()
	reg.compile("^[A-Za-z0-9]+$")
	
	var char: String = ""
	
	for item in range(0, _value.length()):
		
		#print("char > ", char)
		
		char = _value[item]
		
		# 处理 \\ 后面紧接着的字符
		if pos != -1:
			
			match char:
				
				# 组合为 \b
				"b":
					
					result += "\b"
				
				# 组合为 \t
				"t":
					
					result += "\t"
				
				# 组合为 \t
				"n":
					
					result += "\n"
				
				# 组合为 \f
				"f":
					
					result += "\f"
				
				# 组合为 \r
				"r":
					
					result += "\r"
				
				# 得到 "
				'"':
					
					result += '"'
				
				# 得到\u
				"u":
					
					# 判断是否已经是 \u 模式
					# \u0022\u0022 这种情况
					cache_unicod = "\\u"
					is_unicod = true
				
				# 组合为 \\,即 \
				"\\":
					
					result += "\\"
				
				# 其他
				_:
					
					assert(false, "错误的转义")
			
			pos = -1
			
			continue
		
		# 如果遇到转义
		if _value[item] == "\\":
			
			# 判断是否在 unicod
			if is_unicod:
				
				# 判断是否有效，是否可以作为结尾
				# 返回空即不匹配
				var unicod: String = _check_unicod(cache_unicod)
				
				assert(not unicod.is_empty(), "unicod 不匹配")
				# 添加值
				result += unicod
				is_unicod = false
				cache_unicod = ""
			
			pos = item
		
		# 否则
		else:
			
			# 判断当前是否是 is_unicod
			# 如果是就检查字符并判断长度来加入
			if is_unicod:
				
				# \u00 011
				# 用正则表达式判断字符
				# 如果搜索结果为空就说明到 \u 已经结束了
				if reg.search(char) == null:
					
					# 检查
					var unicod: String = _check_unicod(cache_unicod)
					
					assert(not unicod.is_empty(), "unicod 不匹配")
					
					result += unicod
					is_unicod = false
					cache_unicod = ""
					# 添加字符
					result += char
					continue
				
				cache_unicod += char
				
				# \u0000FFFF
				if cache_unicod.length() == 10:
					
					var unicod: String = _check_unicod(cache_unicod)
					
					assert(not unicod.is_empty(), "unicod 不匹配")
					
					result += unicod
					is_unicod = false
					cache_unicod = ""
					continue
				
				# 判断长度，如果长度超过 4 个就进行检查
				# \u + 4
				elif cache_unicod.length() > 6:
					
					assert(not _check_unicod(cache_unicod).is_empty(), "unicod 不匹配")
				
				continue
			
			result += char
	
	# 检查是否有残留
	if is_unicod and not cache_unicod.is_empty():
		
		var unicod: String = _check_unicod(cache_unicod)
		
		assert(not unicod.is_empty(), "unicod 不匹配")
		
		result += unicod
	
	return result




# 如果是多行呢？
# 在多行情况下，
# """
# 	Hello \
# 	World
# """
# 这是正确的
# 
# """
# 	Hello \ w
# 	World
# """
# 这是错误的
# 也就是是说，在遇到 \ 后
# 紧接着不是遇到上面的字符而是遇到 " " 或 "\t"
# 就需要保证 从现在开始知道遇到 \n （非手动 \n 就是 "\\n"）
# 检查 多行字符串 是否合法
func _check_multiline_doublequotation(_value: String) -> String:
	
	var result: String = ""
	
	var pos: int = -1
	
	# 是否末尾转义 \
	var is_escape_end	: bool = false
	# 末尾转义结束后的附带
	var is_escape_start	: bool = false
	
	# 判断是否 \u
	var is_unicod: bool = false
	var cache_unicod: String = ""
	var reg: RegEx = RegEx.new()
	reg.compile("^[A-Za-z0-9]+$")
	
	var char: String = ""
	
	for item in range(0, _value.length()):
		
		char = _value[item]
		
		# 处理 \\ 后面紧接着的字符
		if pos != -1:
			
			match char:
				
				# 组合为 \b
				"b":
					
					result += "\b"
				
				# 组合为 \t
				"t":
					
					result += "\t"
				
				# 组合为 \t
				"n":
					
					result += "\n"
				
				# 组合为 \f
				"f":
					
					result += "\f"
				
				# 组合为 \r
				"r":
					
					result += "\r"
				
				"u":
					
					cache_unicod = "\\u"
					is_unicod = true
					#print(">>>")
					pass
				
				# 得到 "
				'"':
					
					result += '"'
				
				# 组合为 \\,即 \
				"\\":
					
					result += "\\"
				
				# 多行时
				# Hello \
				# 是合法的但是
				# Hello \ w
				# 是非法的,也就是如果经过了这个 item 之后遇到 item 就会报错
				" ", "\t":
					
					is_escape_end = true
				
				# 如果紧接着换行，就直接启用 is_escape_start
				"\n":
					
					is_escape_start = true
				
				# 其他
				_:
					
					assert(false, "错误的转义")
			
			pos = -1
			continue
		
		# 如果是新行且 is_escape_start 是 ture 就判断一下是不是转义，会忽略转义，直到遇到转义以外的字符
		if is_escape_start:
			
			if	char != "\n" and \
				char != "\t" and \
				char != "\b" and \
				char != " "  and \
				char != "\f" and \
				char != "\r":
					
					# 如果是 \ 转义符号，还需要额外的标记
					if char == "\\":
						
						pos = item
					
					result += char
					is_escape_start = false
			
			continue
		
		# 如果为 ture 会有新的判定
		if is_escape_end:
			
			match char:
				
				
				# 去除结束，标记一个新的值，用来去除转义，直到遇到有效字符
				"\n":
					
					is_escape_end = false
					is_escape_start = true
				
				# \ 会保留在遇到 \n 之前遇到的 \t 与空格
				"\t", " ":
					
					result += char
				
				# 其它的转义无视掉
				"\r", "\b", "\f":
					
					continue
				
				# 其它字符，就报错
				_:
					
					assert(false, "意外的字符")
		
		else:
			
			# 标记手动转义
			if _value[item] == "\\":
				
				# 判断是否在 unicod
				if is_unicod:
					
					# 判断是否有效，是否可以作为结尾
					# 返回空即不匹配
					var unicod: String = _check_unicod(cache_unicod)
					
					assert(not unicod.is_empty(), "unicod 不匹配")
					# 添加值
					result += unicod
					is_unicod = false
					cache_unicod = ""
				
				pos = item
			
			else:
				
				# 判断当前是否是 is_unicod
				# 如果是就检查字符并判断长度来加入
				if is_unicod:
					
					# \u00 011
					# 用正则表达式判断字符
					# 如果搜索结果为空就说明到 \u 已经结束了
					if reg.search(char) == null:
						
						# 检查
						var unicod: String = _check_unicod(cache_unicod)
						
						assert(not unicod.is_empty(), "unicod 不匹配")
						
						result += unicod
						is_unicod = false
						cache_unicod = ""
						# 添加字符
						result += char
						continue
					
					cache_unicod += char
					
					# \u0000FFFF
					if cache_unicod.length() == 10:
						
						var unicod: String = _check_unicod(cache_unicod)
						
						assert(not unicod.is_empty(), "unicod 不匹配")
						
						result += unicod
						is_unicod = false
						cache_unicod = ""
						continue
					
					# 判断长度，如果长度超过 4 个就进行检查
					# \u + 4
					elif cache_unicod.length() > 6:
						
						assert(not _check_unicod(cache_unicod).is_empty(), "unicod 不匹配")
					
					continue
				
				# 紧跟着 \n 的 开头 将被无视掉
				if char == "\n" and item == 0:
					
					continue
				
				result += char
	
	# 检查是否有残留
	if is_unicod and not cache_unicod.is_empty():
		
		var unicod: String = _check_unicod(cache_unicod)
		
		assert(not unicod.is_empty(), "unicod 不匹配")
		
		result += unicod
	
	return result





# 判断 Unicod 是否有效
func _check_unicod(_unicod: String) -> String:
	
	var result: String = ""
	
	#print("_unicod :", _unicod, "<<<")
	
	var reg: RegEx = RegEx.new()
	
	reg.compile("\\\\u([0-9A-Fa-f]{4})|\\\\U([0-9A-Fa-f]{8})/g")
	
	var res: RegExMatch = reg.search(_unicod)
	
	if res:
		
		result = res.get_string()
	
	return result
