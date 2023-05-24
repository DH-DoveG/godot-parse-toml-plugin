
#===========================================
# 介绍：用于解析数组
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name DHTomlParseArray
extends Node




func parse(_value: String) -> Array:
	
	# [...] 这要去掉两边的 中括号 来解析
	var value: String = _value.substr(1, _value.length() - 2)
	
	return _check_array(value)




# 检查数组
func _check_array(_value: String) -> Array:
	
	var current: Array = []
	
	# 记录深度对应的数组
	var tree: Dictionary = {
		
		0: current
		
	}
	
	# 当前深度
	var depth: int = 0
	
	# 根
	var root: Array = current
	
	# 单引号
	var inQuotes: bool = false
	var is_m_s: bool = false
	
	# 双引号
	var inDoubleQuotes: bool = false
	var is_m_d: bool = false
	
	# 转义
	var is_e: bool = false
	
	# 字典
	# 能通过 token 检查的字典都是完整的
	var is_d: int = 0
	
	var cache: String = ""
	var char: String = ""
	
	var pos: int = 0
	
	while pos < _value.length():
		
		char = _value[pos]
		
		# 如果遇到 [,就 + 1 层级
		if char == "["		and \
			is_d == 0		and \
			not is_m_s		and \
			not inQuotes	and \
			not is_m_d		and \
			not inDoubleQuotes:
			
			var sub_arr: Array = []
			current.append(sub_arr)
			
			# 获取现在的深度并加深当前层级
			var next: int = tree.size()
			
			depth += 1
			tree[next] = sub_arr
			current = sub_arr
		
		# 如果遇到] ,就 - 1 层级
		elif char == "]"	and \
			is_d == 0		and \
			not is_m_s		and \
			not inQuotes	and \
			not is_m_d		and \
			not inDoubleQuotes:
			
			depth -= 1
			
			# 要跳到上一层，先看一下 cache 是不是有值
			if cache != "":
				
				current.append(cache)
				cache = ""
			
			# 完结
			if depth == -1:
				
				break
			
			else:
				
				current = tree[depth]
		
		elif char == "{" and not is_m_s and not inQuotes and not is_m_d and not inDoubleQuotes:
			
			cache += char
			is_d += 1
		
		elif char == "}" and not is_m_s and not inQuotes and not is_m_d and not inDoubleQuotes:
			
			cache += char
			is_d -= 1
		
		# 等到遇到 , 并且不在字符串内才会添加值
		elif char == "," and is_d == 0 and not is_m_s and not inQuotes and not is_m_d and not inDoubleQuotes:
			
			# 如果 cache 为空就报错
			# 如：[1,2,,] 或 [,1,2]
			# 允许尾逗号
			# 如：[1,2,]
			assert(not cache.is_empty(), "错误的','号")
			
			current.append(cache)
			cache = ""
		
		elif char != " " and char != "\t":
			
			# 在 " 或 ' 就加入
			if char == "'":
				
				# 判断是否 启用 多行
				if _value.substr(pos, 3) == "'''":
					
					# 如果已经启用就关闭
					is_m_s = not is_m_s
					
					cache += "'''"
					pos += 3
					continue
				
				# 结尾也允许 ''
				elif is_m_s and _value.substr(pos, 2) == "''":
					
					is_m_s = false
					cache += "''"
					pos += 2
					continue
				
				cache += char
				
				inQuotes = not inQuotes
			
			elif char == '"':
				
				# 判断是否 启用 多行
				if _value.substr(pos, 3) == '"""':
					
					# 如果已经启用就关闭
					is_m_d = not is_m_d
					
					cache += '"""'
					pos += 3
					continue
				
				# 结尾也允许 ""
				elif is_m_d and \
					_value.substr(pos, 2) == '""':
					
					is_m_d = false
					cache += '""'
					pos += 2
					continue
				
				cache += char
				inDoubleQuotes = not inDoubleQuotes
			
			else:
				
				cache += char
		
		elif inDoubleQuotes or \
			inQuotes or \
			is_m_s or \
			is_m_d:
			
			cache += char
		
		pos += 1
	
	if cache != "":
		
		current.append(cache)
	
	return root
