
class_name GTomlParseDictionary
extends Node




# 解析 value 为字典
func parse_value( _value: String ) -> Dictionary:
	
	var value: String = _value.strip_edges()
	value = value.substr( 1, value.length() - 2 )
	
	return _check_dictionary_value( value )




# 解析 value 为 路径
func parse_key( _key: String ) -> PackedStringArray:
	
	var key: String = _key.strip_edges()
	
	return _check_dictionary_key( key )




# 调整字典
# key需要是一个数组
# {
#	["a", "a"] : 0,
#	["a", "b"] : 1
# }
# 解析应该得到:
# {
#	"a": {
# 		"a": 0,
#		"b": 1
#	}
# }
# 0 号位是根
func adjust( _dic: Dictionary ) -> Dictionary:
	
	var result: Dictionary = {}
	
	#print( "adjust>>", _dic )
	
	# 注册路径
	# 如果当前走的路径的记录与注册过的路径重复就报错
	# 判断逻辑
	# 1. 当前路径 不能是 注册路径中的 end, 也就是当前路径不能与注册路径的任何一项完全匹配
	#	> { a.b.c = 0, a.b.c.d = 0 }	F
	#	> { a.b.c = 0, a.b.e = 0 }		T
	# 2. 当前路径的终点 不能是 注册路径从开始起的一段路径
	#	> { a.b.c.d.e.f = 0, a.b.c.d = 1 }	F
	#	> { a.b.c.d.e.f = 0, a.b.c.e = 1 }	T
	var save_load: Array = []
	var curr_load: PackedStringArray = []
	
	var pos: int = 0
	var end: int = 0
	
	var after: Dictionary = {}
	
	# [ 1,2,3 ] : 233
	for keys in _dic:
		
		pos = 0
		end = keys.size() - 1
		after = result
		
		
		# 先检查路径是否合法
		for key in keys:
			
			var load = after.get( key )
			
			# 保存路径
			curr_load.push_back( key )
			
			# 检查路径
			for item in save_load:
				
				# 比较路径
				# 必须得到一个 null 否则说明路径重复来，报错
				assert( item != curr_load, "与之前的路径冲突" )
				
				# 如果已经进行到末尾，就做彻底的检查
				if pos == end:
					
					var is_legal: bool = true
					
					for save in save_load:
						
						for curr in range( 0, curr_load.size() ):
							
							# 不需要担心下标越位，到这里的只可能长度相同或比 curr_load 更长
							#print( curr )
							if curr_load[ curr ] == save[ curr ]:
								
								is_legal = false
							
							# 只要有一次不匹配就直接开始检查下一个
							else:
								
								is_legal = true
								break
						
						assert( is_legal, "路径重复设置" )
			
			
			# 如果道路是未开辟的
			if load == null:
				
				# 如果到了最后一个位置
				if pos == end:
					
					after[ key ] = _dic[ keys ]
				
				# 如果还没有到最后一个位置
				# 就深入一层
				else:
					
					after[ key ] = {}
					
					after = after[ key ]
			
			
			# 如果道路已开辟
			# 且是 字典类型
			# 就可以借这条道路进行增加值
			elif typeof( load ) == TYPE_DICTIONARY:
				
				# 判断一下
				# 如果已经到了底下
				if pos == end:
					
					# 因为已经有人来过，判断一下是否key冲突
					assert( load.get( key ) == null, "key冲突" )
					
					after[ key ] = _dic[ keys ]
				
				# 如果没到底的话，路径相同是允许的
				else:
					
					after = after[ key ]
				
				pass
			
			# 如果遇到的不是 字典类型就报错
			else:
				
				assert( false, "路径冲突" )
			
			pos += 1
		
		# 保存路径
		save_load.push_back( curr_load )
		curr_load = []
	
	return result




# 内联表不允许嵌套
# ERROR: d = {{}}
# 内联表通过逗号分割
# CORRECT: d = {k1={},k2={}}
# ERROR: d= {1,2}
# 内联表不支持尾逗号
# ERROR: d= {k1=0,k2=1,}
# 内联表中的 key 名不能为多行
# ERROR: d = {k1=[], "k2"=[], """why""" = 0}
# 
# 合法的内联表: {k1=0,k2=1,k3={kk1=0}}
# 本方法应返回: {"k1": "0", "k2": "1", "k3": "kk1=0" }
func _check_dictionary_value( _value: String ) -> Dictionary:
	
	#print( "_value o ||", _value.c_escape(), "|| size >>", _value.length() )
	
	# 检查是否有不合法的换行
	# 如果从两边是开始找，在遇到第一个有效字符前遇到了 \n 就说明这是错误的
	# key = { 
	#	key = []
	# }
	# 上面的例子是错误的，在获取时会得到前后两个 \n
	# key = { key = [
	# ]
	# }
	# 这也是错误的
	# key = {
	#	key = [
	#	]}
	# 这也是错误的
	var end_pos		: int = _value.length() - 1
	var begin_pos	: int = 0
	
	while begin_pos != -1 and end_pos != -1:
		
		#print( "begin_pos >", begin_pos, "|| end_pos >", end_pos )
		
		if begin_pos != -1 and (
			_value[ begin_pos ]	!= "\t" and \
			_value[ begin_pos ]	!= "\n" and \
			_value[ begin_pos ]	!= "\f" and \
			_value[ begin_pos ]	!= "\b" and \
			_value[ begin_pos ]	!= "\r" and \
			_value[ begin_pos ]	!= " " ):
			
			begin_pos = -1
		
		if end_pos != -1 and (
			_value[ end_pos ]	!= "\t" and \
			_value[ end_pos ]	!= "\n" and \
			_value[ end_pos ]	!= "\f" and \
			_value[ end_pos ]	!= "\b" and \
			_value[ end_pos ]	!= "\r" and \
			_value[ end_pos ]	!= " " ):
			
			end_pos = -1
		
		if begin_pos != -1:
			
			assert( _value[ begin_pos ] != "\n", "错误的换行" )
			begin_pos += 1
		
		if end_pos != -1:
			
			assert( _value[ end_pos ] != "\n", "错误的换行" )
			end_pos -= 1
	
	# 清除两边的转义
	_value = _value.strip_edges()
	
	#print( "_value e >> ", _value.c_escape() )
	
	# 如果传入的是空字符串
	if _value.is_empty():
		
		return {}
	
	var result: Dictionary = {}
	
	var key		: String = ""
	var char	: String = ""
	var cache	: String = ""
	
	var is_singlequote					: bool = false
	var is_doublequotation				: bool = false
	var is_multiline_singlequote		: bool = false
	var is_multiline_doublequotation	: bool = false
	
	var pos					: int = 0
	var is_type_array		: int = 0
	var is_type_dictionary	: int = 0
	
	# 检查
	while pos < _value.length():
		
		char = _value[ pos ]
		
		#print( 
		#	"char>>> ", char.c_escape(),
		#	" | is_singlequote>>> ", is_singlequote,
		#	" | is_doublequotation>>> ", is_doublequotation,
		#	" | is_multiline_singlequote>>>", is_multiline_singlequote,
		#	" | is_multiline_doublequotation>>>", is_multiline_doublequotation,
		#	" | is_type_array>>>", is_type_array,
		#	" | is_type_dictionary>>>", is_type_dictionary,
		#	" | key>>>", key,
		#	" | cache>>>", cache
		#)
		
		match char:
			
			
			"'":
				
				if is_type_dictionary or is_type_array:
					
					cache += char
					pos += 1
					continue
				
				# 判断是否在双引号字符串之中
				# 是就直接加入
				if is_multiline_doublequotation or \
					is_doublequotation:
					
					cache += char
					pos += 1
					continue
				
				# 判断是不是多行
				if _value.substr( pos, 3 ) == "'''":
					
					# 判断 key 是不是空
					# 作为key不能是多行字符串
					assert( not key.is_empty(), "多行字符串不能作为 key" )
					
					is_multiline_singlequote = not is_multiline_singlequote
					cache += "'''"
					pos += 3
					continue
				
				# 判断结尾
				elif is_multiline_singlequote and \
					_value.substr( pos, 2 ) == "''":
					
					is_multiline_singlequote = false
					cache += "''"
					pos += 2
					continue
				
				else:
					
					is_singlequote = not is_singlequote
					cache += char
			
			
			'"':
				
				if is_type_dictionary or \
					is_type_array:
					
					cache += char
					pos += 1
					continue
				
				# 判断是否在单引号字符串之中
				# 是就直接加入
				if is_singlequote or \
					is_multiline_singlequote:
					
					cache += char
					pos += 1
					continue
				
				# 判断是不是多行
				if _value.substr( pos, 3 ) == '"""':
					
					# 判断 key 是不是空
					# 作为key不能是多行字符串
					assert( not key.is_empty(), "多行字符串不能作为 key" )
					
					is_multiline_doublequotation = not is_multiline_doublequotation
					cache += '"""'
					pos += 3
					continue
				
				# 判断结尾
				elif is_multiline_doublequotation and \
					_value.substr( pos, 2 ) == '""':
					
					is_multiline_doublequotation = false
					cache += '""'
					pos += 2
					continue
				
				else:
					
					is_doublequotation = not is_doublequotation
					cache += char
			
			
			"[":
				
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_singlequote:
					
					cache += char
				
				else:
					
					is_type_array += 1
					cache += char
			
			
			"]":
				
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_singlequote:
					
					cache += char
				
				else:
					
					is_type_array -= 1
					cache += char
			
			
			"{":
				
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_singlequote				or \
					is_type_array:
					
					cache += char
				
				else:
					
					is_type_dictionary += 1
					cache += char
			
			
			"}":
				
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_singlequote				or \
					is_type_array:
					
					cache += char
				
				else:
					
					is_type_dictionary -= 1
					cache += char
			
			
			"=":
				
				if is_type_dictionary:
					
					cache += char
					pos += 1
					continue
				
				# 如果缓存为空就报错
				assert( not cache.is_empty(), "key为空" )
				
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_singlequote:
					
					cache += "="
				
				else:
					
					key = cache
					cache = ""
			
			
			",":
				
				# 如果在字典、数组、字符串中就直接加入而不视为分割符
				if is_multiline_doublequotation	or \
					is_multiline_singlequote	or \
					is_doublequotation			or \
					is_type_dictionary			or \
					is_singlequote				or \
					is_type_array:
					
					cache += ","
				
				# 遇到这个的时候就刷新缓存
				else:
					
					assert( not ( not key.is_empty() and cache.is_empty() ), "value为空" )
					assert( result.get( key ) == null, "key冲突" )
					
					result[ key ] = cache
					cache = ""
					key = ""
			
			
			" ", "\n":
				
				if is_type_dictionary or \
					is_type_array:
					
					cache += char
					pos += 1
					continue
				
				# 如果没有缓存且不在字符串内就不加入空格
				if not cache.is_empty() and \
					( is_multiline_doublequotation	or \
					is_multiline_singlequote		or \
					is_doublequotation				or \
					is_singlequote ):
					
					cache += char
			
			
			"\\":
				
				# 判断转义是否在字符串之内，不在就报错
				# 如果转义在数组内也不管
				assert( is_multiline_doublequotation	or
						is_multiline_singlequote		or
						is_doublequotation				or
						is_singlequote					or
						is_type_array,
						"字符串外的转义" )
				
				cache += char
			
			
			_:
				
				cache += char
		
		
		pos += 1
	
	# 末尾缓冲
	# 如果 key == "" cache == "" 就不行
	# 如果说有缓存无key
	# 例如: {key}
	# 有key无value
	# 例如: {key=   }
	# 正常情况下是会有一个来留给这一段来进行刷新的，除非有多余的尾逗号
	# key=0,key2=0
	assert( not key.is_empty() and not cache.is_empty(), "刷新错误" )
	# 如果 key 不为空 且 cache 为空
	assert( not ( not key.is_empty() and cache.is_empty() ), "value为空" )
	# 如果 key 已设置
	assert( result.get( key ) == null, "key冲突" )
	
	result[ key ] = cache
	cache = ""
	key = ""
	
	return result



# 解析 key
func _check_dictionary_key( _key: String ) -> PackedStringArray:
	
	#print( "key >", _key )
	
	# key.hh
	# 解析>> [ "key", "hh" ]
	# key."hh"
	# 解析>> [ "key", "\"hh\"" ]
	# 解析之后需要确定键名的合法性
	# 不在双引号里面的只允许是 a-z A-Z 0-9 -_
	# ^[A-Za-z0-9_-]+$
	#TODO
	
	var loads: PackedStringArray = []
	
	var cache	: String = ""
	var char	: String = ""
	
	var is_doublequotation	: bool = false
	var is_singlequote		: bool = false
	var is_escape			: bool = false
	
	var pos: int = 0
	
	while pos < _key.length():
		
		char = _key[ pos ]
		
		match char:
			
			".":
				
				if is_doublequotation or is_singlequote:
					
					cache += char
				
				else:
					
					assert( not cache.is_empty(), "key" )
					
					loads.push_back( cache )
					cache = ""
			
			"'":
				
				if is_doublequotation:
					
					pass
				
				elif is_singlequote:
					
					is_singlequote = false
				
				else:
					
					is_singlequote = true
				
				cache += char
			
			
			'"':
				
				if is_singlequote:
					
					pass
				
				elif is_escape:
					
					is_escape = false
				
				elif is_doublequotation:
					
					is_doublequotation = true
				
				else:
					
					is_doublequotation = false
				
				cache += char
			
			"\\":
				
				if is_singlequote:
					
					cache += char
				
				else:
					cache += char
					
					is_escape = not is_escape
			
			_:
				
				if is_escape:
					
					is_escape = false
				
				cache += char
		
		pos += 1
	
	loads.push_back( cache )
	
	#print( "loads >", loads )
	
	return loads
