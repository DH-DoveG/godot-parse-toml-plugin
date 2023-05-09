
#===========================================
# 介绍：用于合并 GTomlTokenObject 的数据
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name GTomlMerge
extends Node




# 数据
var data: Dictionary = {}

# 保存的路径
var save_load: Array = []

# 根路径
var root_load: PackedStringArray = []

var root_is_array: bool = false




# 清除数据
func clear() -> void:
	
	root_is_array = false
	root_load.clear()
	save_load.clear()
	data.clear()




# 返回 data 值
func data_get() -> Dictionary:
	
	var result: Dictionary = data.duplicate()
	
	clear()
	
	return result




# 合并
# 根据键名来合并
# 注意 LIST 模式的值
# key 决定相对路径
# LIST 决定当前根路径
# 需要保存注册过的路径来放置冲突
#TODO
func merge( _token: GTomlTokenObject ) -> void:
	
	#print( "parse_key || ", _token.parse_key, "\nparse_value || ", _token.parse_value )
	
	var is_not_list_array: bool = true
	
	# 判断 token 类型，如果是 LIST 类型就改变根路径
	if _token.type == GTomlTokenObject.TOKEN_TYPE.LIST:
		
		root_load = _token.parse_key
		root_is_array = _token.is_list_array
		
		if root_is_array:
			
			# 设置 表数组
			# 先看看是否冲突
			is_not_list_array = _check_load( root_load )
			
			# 如果是表数组
			if not is_not_list_array:
				
				# 添加新字典
				#print( ">>", data[ root_load[ 0 ] ] )
				
				data[ root_load[ 0 ] ].append( {} )
			
			# 设置
			# 因为 root_load 一定是单个元素，所以直接取值
			else:
				
				data[ root_load[ 0 ] ] = [{}]
	
	else:
		
		# root 路径 + key
		#print( " load || ", root_load + _token.parse_key )
		
		var target_load	: PackedStringArray = root_load + _token.parse_key
		var curr_load	: PackedStringArray = []
		var after		: Dictionary = data
		
		var begin	: int = 0
		var pos		: int = 0
		var end		: int = target_load.size() - 1
		
		# 判断一下是否在表数组中
		# 是的话就调整一下
		if root_is_array:
			
			# 在就加入一下
			# 进入数组的表中
			# [{}]
			#print( "-->", after[ target_load[0] ].back() )
			after = after[ target_load[ 0 ] ].back()
			curr_load.push_back( target_load[ 0 ] )
			
			begin = 1
			pos = 1
		
		var load: String = ""
		var curr: Variant = null
		
		for item in range( begin, target_load.size() ):
			
			load = target_load[ item ]
			
			# 尝试获取 load
			curr = after.get( load )
			
			curr_load.push_back( load )
			
			# 如果 ag 为空
			if curr == null:
				
				# 判断一下是不是到末尾了
				if pos == end:
					
					# 如果不是表数组
					# 就会进行路径检查
					if not is_not_list_array:
						
						assert( _check_load( curr_load ), "路径冲突" )
					
					after[ load ] = _token.parse_value
				
				# 更进一层
				else:
					
					after[ load ] = {}
					
					after = after[ load ]
			
			# 不为空，就需要判断一下 ag 的类型
			elif typeof( curr ) == TYPE_DICTIONARY:
				
				# 判断一下是不是到末尾了
				if pos == end:
					
					assert( _check_load( curr_load ), "路径冲突" )
					
					after[ load ] = _token.parse_value
				
				# 更进一层
				else:
					
					after = after[ load ]
			
			# 如果不为空而且不是字典类型就报错
			else:
				
				assert( false, "路径冲突" )
			
			pos += 1
			
			pass
	
		save_load.push_back( target_load )




# 验证路径合法性
# 例子
# save > a.b.c
# [F] curr > a.b
# [F] curr > a.b.c
# [F] curr > a
# [F] curr > a.b.c.d
# >> curr路径 不能是 save路径 的整体
# >> curr路径 不能与 save路径 完全匹配
# >> curr路径 可以是 save路径的末尾延续
func _check_load( _load: PackedStringArray ) -> bool:
	
	var key: bool = true
	
	for load in save_load:
		
		# 比较路径
		# 必须得到一个 null 否则说明路径重复来，报错
		#assert( load != _load, "与之前的路径冲突" )
		if load == _load:
			
			return false
		
		key = true
		
		# 判断长度
		# 如果 _load 长于 load，就反过来
		for item in \
			range( 0, _load.size() ) \
			if load.size() >= _load.size() \
			else range( 0, load.size() ) :
			
			if _load[ item ] == load[ item ]:
				
				key = false
			
			# 只要出现不匹配就直接开始检查下一个
			else:
				
				key = true
				break
			
		if not key:
			
			return false
		#assert( key, "路径重复设置" )
	
	return true
