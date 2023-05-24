
#===========================================
# 介绍：对 .toml 文件内容进行初步的解析，生成
#      DHTomlTokenObject 对象
# 
# 
# 作者：DH-DoveG
#===========================================

class_name DHTomlToken
extends Node




# 记录的 key 值
var key			: String = ""

# 记录的 value 值
var value		: String = ""

# 当前遍历到的字符
var char		: String = ""

# 当前的缓存值
var cache		: String = ""


# 记录的行数
var line_number		: int = 0

# 当前遍历的位置
var pos				: int = 0

# 判断是不是在字典中
# 采用 int 类型是为了标记配对情况
var is_dictionary	: int = 0

# 判断是不是在数组中
# 采用 int 类型是为了标记配对情况
var is_array		: int = 0


# 判断是否在单引号字符串中
var is_singlequote					: bool = false

# 判断是否在双引号字符串中
var is_doublequotation				: bool = false

# 判断是否在单引号的多行字符串中
var is_multiline_singlequote		: bool = false

# 判断是否在双引号的多行字符串中
var is_multiline_doublequotation	: bool = false


# 该变量用于确定是否对 value 的类型进行获取
# 判断是否是 = 号后的第一个
var is_write_type	: bool = false

# 判断是不是表
var is_list			: bool = false

# 判断是否转义
# 有这种情况: "\"" = 0
var is_escape		: bool = false


# 保存所有 token
var tokens	: Array[DHTomlTokenObject] = []

# 确定 token 类型
var is_type: DHTomlTokenObject.TOKEN_TYPE = DHTomlTokenObject.TOKEN_TYPE.NULL




# 清除 tokens 数据
func clear() -> void:
	
	key		= ""
	char	= ""
	cache	= ""
	value	= ""
	
	pos				= 0
	is_array		= 0
	line_number		= 0
	is_dictionary	= 0
	
	is_list							= false
	is_escape						= false
	is_write_type					= false
	is_singlequote					= false
	is_doublequotation				= false
	is_multiline_singlequote		= false
	is_multiline_doublequotation	= false
	
	is_type = DHTomlTokenObject.TOKEN_TYPE.NULL
	
	tokens.clear()




# 返回 tokens 的副本并清除掉记录
func get_tokens() -> Array[DHTomlTokenObject]:
	
	var result = tokens.duplicate()
	
	clear()
	
	return result




# 检查值是否全部解析完毕
# 正确的解析完毕 cache 与 key 应该为空
func check() -> bool:
	
	if cache.is_empty() and \
		key.is_empty():
		
		return true
	
	return false




# 解析传入的 line
# 需要传入解析 line 与行数（这将作为key来使用）
# 解析结果将保存到 tokens 之中
func parse(_line: String, _number: int) -> void:
	
	#print("line ?", line)
	
	while pos < _line.length():
		
		char = _line[pos]
		
		#print("char>", char)
		
		# 说起来，既然有了 is_type 就可以做更严苛的判断了
		# 例如：
		# 如果类型是多行字符串
		# 那么在多行字符串收尾后还存在字符未判断（注释除外）
		# 也就是说在 类型 完整时如果后面还有有效字符就报错
		# OTHER 类型除外
		if not _is_str():
			
			_is_full()
		
		# 如果当前是转义模式要看一下当前字符是否是有意义的转义
		# 转义，类似于：st\r = "str" 是错误的
		# 这会读取到： <s> <t> <\\> <r> <=> <"><s><t><r><">
		# 是错误的，只有在字符串中才接受 \\ -> 也就是单个 \ 字符
		# 它需要紧接着的后一个字符来验证这个转义的合法性
		# 在字符串外不接受任何手动转义 \\
		# - \b：退格符
		# - \t：水平制表符
		# - \n：换行符
		# - \f：换页符
		# - \r：回车符
		# - \"：双引号
		# - \'：单引号
		# - \\：反斜杠
		if is_escape:
			
			# 不在 字符串 里的手动转义是错误的
			assert(_is_str(), "错误的转义")
			
			# 如果是单行双引号字符串的话
			# 将错误 "\ "
			# 不过这里将不过多的对字符串内容进行检查
		
		# 根据 char 来进行匹配
		match char:
			
			
			"'":
				
				if _char_is_singlequotes(_line):
					
					continue
			
			
			'"':
				
				if _char_is_doublequotation(_line):
					
					continue
			
			
			# 遇到这个需要判断一下当前是不是在字符串内
			# 不在就说明到末尾了，到了末尾就需要 break
			"\n":
				
				# 在字符串内就直接加入
				# 在 {} 之内也要加入
				if _is_str() or is_dictionary:
					
					cache += char
				
				# 不是字符串就结束了
				else:
					
					break
			
			
			# 如果不在字符串中就忽略掉
			"\t":
				
				if _is_str() or not cache.is_empty():
					
					cache += char
			
			
			# 这个...
			# 如果在文本中写 \r 在解析时会得到 \\r 即： \\ 与 r 这两个
			"\r":
				
				if _is_str() or not cache.is_empty():
					
					cache += char
			
			
			# 这一段要求判断一下 key 是不是已经存在了， {} 是不能作为 value 存在的
			"{":
				
				# 判断一下是否在字符串内
				if _is_str():
					
					cache += char
				
				else:
					
					_char_is_dictionary_left()
			
			
			"}":
				
				# 判断一下是否在字符串内
				if _is_str():
					
					cache += char
				
				else:
					
					_char_is_dictionary_right()
			
			
			# 数组也不能作为key，不过如果这一行只有数组就说明是 list
			# 这是合法的
			"[":
				
				# 判断一下是不是在字符串内
				if _is_str():
					
					cache += char
				
				# 不在字符串内，就交由专门的方法处理
				else:
					
					_char_is_array_left(_number)
			
			
			"]":
				
				# 判断一下是不是在字符串内
				if _is_str():
					
					cache += char
				
				# 不在字符串内，就交由专门的方法处理
				else:
					
					_char_is_array_right()
			
			
			# 遇到 # 号，判断是不是在值符串里面
			# 如果不在就直接跳出循环了，因为后面都是注释内容
			"#":
				
				if _is_str():
					
					cache += char
				
				else:
					
					break
			
			
			# 遇到空格
			# 不在字符串内的空格都将无视掉
			# 但是这只适用于在 cache 等于 "" 时于，因为：
			# ke y = 123 456 789
			# 如果解析得到： key=123456789 这是错误的
			# 应该： ke y =123 456 789
			" ":
				
				if _is_str() or not cache.is_empty():
					
					cache += char
			
			
			# 如果遇到 = 号可能是找到了分界点
			"=":
				
				# 如果遇到 = 号，需要先判断是不是在字符串内
				# 如果在字符串内就直接将这个等号加入到 cache 中
				# 如果不在就说明 key 已经完成了截取
				if _is_str():
					
					cache += char
				
				# 还需要判断是否在内联表内
				# 如果已经存在 key
				# 如果在内联表内也直接加入 cache 中即可
				if not key.is_empty() and is_dictionary > 0:
					
					cache += char
				
				# 如果不是就确认是否找到过 "=" 了
				else:
					
					# 要先确认 key 是不是空
					# key 为空就设置当前缓存为 key
					if key.is_empty():
						
						# 判断一下，如果要设置为 key 的话，需要保证 is_list 等于 false
						# 如果不等于 false 就说明试图用 数组 来作为 key
						# 也需要保证 is_dictionary 等于 0
						assert(not is_list, "试图用数组来作为 key")
						assert(is_dictionary == 0, "试图用内联表作为 key")
						
						# 记录 key 并重置缓存
						key = cache
						cache = ""
						
						# 记录行数
						line_number = _number
						
						# 设置将下一个有效字符作为类型
						is_write_type = true
					
					# 不是空，而且不在字符串、字典的情况
					# *字典： dic = {k1=0,k2=1}
					# 就报错
					if _is_str() and is_dictionary == 0:
						
						assert(false, "额外的 = 号")
			
			
			"\\":
				
				# 如果在 ' 原始字面量就无视 \\ 的转义，直接加入
				# 如果不在才进行转义判断
				if is_type != DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_SINGLEQUOTE and \
					is_type != DHTomlTokenObject.TOKEN_TYPE.STRING_SINGLEQUOTE:
					
					is_escape = not is_escape
				
				# 这在 " Work\" " 中有出现可能
				# 这样的话，依旧将 \ 添加入 cache 中
				# 如果是又一次触发，就说明是 \\ 这需要加入 cache 中
				# 所以无论哪种情况都需要添加入 cache
				cache += char
			
			
			# 其它情况直接加就好
			_:
				
				# 判断是否作为 类型
				if is_write_type:
					
					is_type = DHTomlTokenObject.TOKEN_TYPE.OTHER
					is_write_type = false
		
				
				# 取消转义状态
				is_escape = false
				
				cache += char
		
		# 位置向后移一格
		pos += 1
	
	#print(	"is_m_d> ",		is_multiline_doublequotation,	\
	#		" || is_m_s> ",	is_multiline_singlequote,		\
	#		" || is_d> ",	is_doublequotation,				\
	#		" || is_s>",	is_singlequote,					\
	#		" || is_a>",	is_array
	#)
	
	#print(	"key> ",		key,	\
	#		" || cache>",	cache,	\
	#		" || is_list>",	is_list
	#)
	
	# 重置位置
	pos = 0
	
	# 如果 他们都等于 0
	# 就将缓存给予 value
	# 就说明截取完成了，输出一下 key 与 value 然后保存他们并设置 key 与 value 为空
	if not is_multiline_doublequotation and \
		not is_multiline_singlequote	and \
		not is_doublequotation			and \
		not is_singlequote				and \
		is_dictionary	== 0			and \
		is_array		== 0:
		
		value += cache
		cache = ""
		
		#print("key>>", key, "\nvalue>>", value)
		
		# 如果 key 与 value 都为空就说明遇到了空白行
		# 因为不在字符串中的转义字符不会被收集，所以空行打 tab、空格 也符合这个条件
		if key.is_empty() and value.is_empty():
			
			return
		
		# 如果有 value 没 key 也是错误的
		# 例如： k
		# 还有一种：[list]
		# 这要判断一个 is_list 标记
		# 如果标记为 false 就属于情况一
		if not is_list and \
			key.is_empty() and \
			not value.is_empty():
			
			assert(false, "缺少key值")
		
		# 如果 key 不等于空而 value 等于空。然后， line_number 等于当前 number
		# 只有key没有value是错误的
		# 例如： key=
		if not key.is_empty() and \
			value.is_empty() and \
			line_number == _number:
			
			assert(false, "缺少value值")
		
		# 如果是 list
		if is_list:
			
			# 设置token类型
			is_type = DHTomlTokenObject.TOKEN_TYPE.LIST
			# 取消标记
			is_list = false
		
		var token_object = DHTomlTokenObject.new()
		
		token_object.original_value = value
		token_object.original_key = key
		token_object.type = is_type
		token_object.line = line_number
		
		tokens.append(token_object)
		
		# 记录tokens
		#tokens[line_number] = {
		#	"key"	: key,
		#	"value"	: value,
		#	"type"	: is_type
		#}
		
		# 重置
		key		= ""
		value	= ""
		is_type	= DHTomlTokenObject.TOKEN_TYPE.NULL
		
		return
	
	
	
	# 看一下是不是 is_doublequotation 和 is_singlequote 不为 0
	# 因为这两个是单行的
	# 这说明数据不完整
	# 如果是的话就报错
	#print("is_d >", is_doublequotation, "||is_s >", is_singlequote)
	if is_doublequotation or \
		is_singlequote:
		
		assert(false, "单行字符串不完整")
	
	# 内联表是只允许单行的，不允许多行
	# 如果读取该行结束，表并没有匹配结束，就说明是数据不完整
	if is_dictionary != 0:
		
		# 可是内联表还有一个意外，就是如果有换行在值内是合法的时侯
		# 这将是被允许的,
		# 所以还需要满足下面的条件
		# 数组和多行字符串都是允许换行的
		if not is_multiline_doublequotation and \
			not is_multiline_singlequote and \
			is_array == 0:
			
			assert(false, "内联表不完整")
	
	# 看一下 is_multiline... 系列的与 is_array
	# 因为这3者是可以多行的
	if is_multiline_doublequotation or \
		is_multiline_singlequote:
		
		value += cache
		cache = ""
	
	# 看一下 is_list
	# 如果 is_list 成立呃且 is_array 不等于 0
	# 就报错
	if is_list and \
		is_array != 0:
		
		assert(false, "表不完整")
	
	return




# 是不是值符串的判断
func _is_str() -> bool:
	
	return is_multiline_doublequotation	or \
			is_multiline_singlequote	or \
			is_doublequotation			or \
			is_singlequote




# 判断字符串采集是否已经完整
# 不判断是否不完整
# 只判断是否已经完整了还继续收集
func _is_full() -> void:
	
	var full = false
	
	match is_type:
		
		DHTomlTokenObject.TOKEN_TYPE.STRING_SINGLEQUOTE:
			
			if not is_singlequote:
				
				full = true
		
		DHTomlTokenObject.TOKEN_TYPE.STRING_DOUBLEQUOTATION:
			
			if not is_doublequotation:
				
				full = true
		
		DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_SINGLEQUOTE:
			
			if not is_multiline_singlequote:
				
				full = true
		
		DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_DOUBLEQUOTATION:
			
			if not is_multiline_doublequotation:
				
				full = true
		
		DHTomlTokenObject.TOKEN_TYPE.DICTIONARY:
			
			# 字典已经收集完整
			if is_dictionary == 0:
				
				full = true
		
		DHTomlTokenObject.TOKEN_TYPE.ARRAY:
			
			if is_array == 0:
				
				full = true
		
		_:
			pass
	
	if full:
		
		# 如果已经完整，而 char 又不是列举的这些，就报错
		assert(char == "\n" or
				char == "\t" or
				char == " "  or
				char == "#"  or
				char == "\r",
				"多余的额外字符")




# char = "
# 返回 0 表示不跳转
# 返回 1 表示跳转 continue
func _char_is_doublequotation(_line: String) -> bool:
	
	# 看一下有没有转义
	if is_escape:
		
		# 如果转义的话就要看一下当前是不是在 is_doublequotation 中
		# 或者 is_singlequote 中
		# 如果在的话就直接加入不视为结尾
		# (这表示在字符串内的转义 ")
		if  _is_str():
			
			# 使用掉转义
			is_escape = false
			cache += char
			pos += 1
			
			return true
		
		# 如果都不是的话就报错，因为 ke\"y" = 0 或是 key = "\" 很明显是错误的
		else:
			
			assert(false, "错误的转义")
		
		# 完成后去掉转义状态
		is_escape = false
	
	# 需要判断一下，现在是不是在 ''' 或 ' 之内
	# key = ''' """ """ '''
	if is_type == DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_SINGLEQUOTE or \
		is_type == DHTomlTokenObject.TOKEN_TYPE.STRING_SINGLEQUOTE:
		
		cache += '"'
		
		return false
	
	# 判断是不是多行字符串
	if _line.substr(pos, 3) == '"""':
		
		# 多行值符串不能用在 key 名，所以在 = 之前遇到 """ 就是错误的
		# 因为不允许 """ 所以也不需要判断 “”“ 是否是完整
		if key.is_empty():
			
			assert(false, "非法键值")
		
		# 已经标记有值就设置值为0
		elif is_multiline_doublequotation:
			
			is_multiline_doublequotation = false
		
		# 标记并添加值
		else:
			
			is_multiline_doublequotation = true
			# 双引号多行的开始
			# 判断是否作为 类型
			if is_write_type:
				
				is_type = DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_DOUBLEQUOTATION
				is_write_type = false
		
		cache += '"""'
		
		# 下标漂移
		pos += 3
		
		return true
	
	# 结尾时，还有可能是 "" 而非 """
	if is_multiline_doublequotation and \
		_line.substr(pos, 2) == '""':
		
		is_multiline_doublequotation = 0
		
		cache += '""'
		pos += 2
		
		return true
	
	# 看一下 is_singlequote 是不是 0
	# 还有 is_multiline... 是不是 0
	# 如果不是 0 就说明是字符串套字符串，直接添加就好
	if is_multiline_doublequotation	or \
		is_multiline_singlequote	or \
		is_singlequote:
		
		# 添加值到缓存
		cache += char
	
	# 标记并加入值
	else:
		
		# 判断一下之前是不是已经标记过双引号了
		# 如果是就取消标记
		if is_doublequotation:
			
			is_doublequotation = false
		
		# 没有就加一
		else:
			
			is_doublequotation = true
			# 双引号字符串的开始
			# 判断是否作为 类型
			if is_write_type:
				
				is_type = DHTomlTokenObject.TOKEN_TYPE.STRING_DOUBLEQUOTATION
				is_write_type = false
		
		# 添加值到缓存
		cache += char
	
	return false




# char = '
# 返回 0 表示不跳转
# 返回 1 表示跳转 continue
func _char_is_singlequotes(_line: String) -> bool:
	
	# 看一下有没有转义
	if is_escape:
		
		# 如果转义的话就要看一下当前是不是在 is_doublequotation 中
		# 或者 is_singlequote 中
		# 如果在的话就直接加入不视为结尾
		# (这表示在字符串内的转义 ")
		if  _is_str():
			
			cache += char
			pos += 1
			
			return true
		
		# 如果都不是的话就报错，因为 ke\'y' = 0 或是 key = '\' 很明显是错误的
		else:
			
			assert(false, "错误的转义")
		
		# 完成后去掉转义状态
		is_escape = false
	
	# 需要判断一下，现在是不是在 """ 或 " 之内
	# key = """ ''' ''' """
	if is_type == DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_DOUBLEQUOTATION or \
		is_type == DHTomlTokenObject.TOKEN_TYPE.STRING_DOUBLEQUOTATION:
		
		cache += "'"
		
		return false
	
	# 判断是不是多行字符串
	if _line.substr(pos, 3) == "'''":
		
		# 多行值符串不能用在 key 名，所以在 = 之前遇到 """ 就是错误的
		# 因为不允许 """ 所以也不需要判断 “”“ 是否是完整
		if key.is_empty():
			
			assert(false, "非法键值")
		
		# 已经标记有值就设置值为0
		elif is_multiline_singlequote:
			
			is_multiline_singlequote = false
		
		# 标记并添加值
		else:
			
			is_multiline_singlequote = true
			
			# 这里是多行的开始
			# 判断是否作为 类型
			if is_write_type:
				
				is_type = DHTomlTokenObject.TOKEN_TYPE.MULTILINE_STRING_SINGLEQUOTE
				is_write_type = false
			
		cache += "'''"
		
		# 下标漂移
		pos += 3
		
		return true
	
	# 结尾时，还有可能是 "" 而非 """
	if is_multiline_singlequote and \
		_line.substr(pos, 2) == "''":
		
		is_multiline_singlequote = 0
		
		cache += "''"
		pos += 2
		
		return true
	
	# 看一下 is_singlequote 是不是 0
	# 还有 is_multiline... 是不是 0
	# 如果不是 0 就说明是字符串套字符串，直接添加就好
	if is_multiline_doublequotation	or \
		is_multiline_singlequote	or \
		is_doublequotation:
		
		# 添加值到缓存
		cache += char
	
	# 标记并加入值
	else:
		
		# 判断一下之前是不是已经标记过双引号了
		# 如果是就取消标记
		if is_singlequote:
			
			is_singlequote = false
		
		# 没有就加一
		else:
			
			is_singlequote = true
			# 单引号字符串的开始
			# 判断是否作为 类型
			if is_write_type:
				
				is_type = DHTomlTokenObject.TOKEN_TYPE.STRING_SINGLEQUOTE
				is_write_type = false
		
		# 添加值到缓存
		cache += char
	
	return false




# 遇到了 [
func _char_is_array_left(_number: int) -> void:
	
	# 判断一下有 key 了没有
	# 如果有 key 了就说明值是 数组
	# 如果没有 key 就有可能是 表
	# 但是如果已经视为 表 了，后面又找到一个 = 就说明尝试将 数组作为 key 名
	# 这将是错误的
	if key.is_empty():
		
		is_array += 1
		cache += '['
		
		is_list = true
		line_number = _number
	
	# 作为 value
	else:
		
		is_array += 1
		cache += '['
		
		# 判断是否作为 类型
		if is_write_type:
			
			is_type = DHTomlTokenObject.TOKEN_TYPE.ARRAY
			is_write_type = false




# 遇到了]
func _char_is_array_right() -> void:

	# 因为匹配了一个
	# 所以将 is_array 值 - 1
	is_array -= 1
	cache += ']'
	
	# 判断是否小于 0
	# 小于 0 就报错
	# 因为这将对应这些非法情况:
	# []]
	#][
	# 如果 is_array 小于 0
	assert(is_array >= 0, "[] 没有完全匹配")




# 遇到了 {
func _char_is_dictionary_left() -> void:
	
	# 判断一下有 key 了没有
	# 如果有就是错误的
	# 因为 {} 不能作为 key
	if key.is_empty():
		
		assert(false, "试图将内联表作为 key")
	
	# 作为 value
	else:
		
		is_dictionary += 1
		cache += '{'
		
		# 判断是否作为 类型
		if is_write_type:
			
			is_type = DHTomlTokenObject.TOKEN_TYPE.DICTIONARY
			is_write_type = false




# 遇到了 }
func _char_is_dictionary_right() -> void:
	
	# 将 is_array 值 - 1
	# 判断是否小于 0
	# 小于 0 就报错
	is_dictionary -= 1
	cache += '}'
	
	assert(is_dictionary >= 0, "没有得到完全匹配")
