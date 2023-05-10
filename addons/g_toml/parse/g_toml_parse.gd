
#===========================================
# 介绍：解析 toml 文件并返回解析得到的值
# 
# 
# 
# 作者：DH-DoveG
#===========================================

class_name GTomlParse
extends Node




var toml_token : GTomlToken = null
var toml_value : GTomlValue = null
var toml_merge : GTomlMerge = null




# 初始化
func _ready():
	
	toml_token = GTomlToken.new()
	toml_value = GTomlValue.new()
	toml_merge = GTomlMerge.new()




# 解析文件
func parse_file( _file_name: String ) -> Dictionary:
	
	# 以只读的方式打开文件，获取文件文本并以 \n 来切分它们
	var file	: FileAccess		= FileAccess.open( _file_name, FileAccess.READ )
	var text	: PackedStringArray	= file.get_as_text().split( "\n" )
	
	#print("---------------------------")
	#print( text )
	#print("---------------------------")
	
	# 需要把截取时消耗掉的 \n 补上
	for item in range( 0, text.size() ):
		
		text[ item ] += "\n"
	
	# 初步解析
	for item in range( 0, text.size() ):
		
		toml_token.parse( text[ item ], item )
	
	# 检查 token 是否全部解析完成
	assert( toml_token.check(), "未解析完成" )
	
	var tokens = toml_token.tokens_get()
	
	#print( "===========================" )
	#print( JSON.stringify( tokens, "\t" ) )
	#print( "===========================" )
	
	var token_parses: Array[ GTomlTokenObject ] = []
	
	# 进一步解析，将 token 都解析为值
	for item in tokens:
		
		#print( "\n===========================" )
		#print( "\tLINE  : ", item.line )
		#print( "\tTYPE  : ", item.type )
		#print( "\tKEY   : ", item.original_key.c_escape() )
		#print( "\tVALUE : ", item.original_value.c_escape() )
		#print( "===========================" )
		
		token_parses.push_back( toml_value.parse( item ) )
	
	# 合并
	for item in token_parses:
		
		toml_merge.merge( item )
	
	#print( "<>==== -------- ====<>" )
	#print( JSON.stringify( toml_merge.data, "\t" ) )
	#print( "<>==== -------- ====<>" )
	
	return toml_merge.data_get()




# 字典转换为 toml
# TODO
func to_toml( _dictionary: Dictionary ) -> String:
	
	return ""

# 解析文件并用于实例化对象
func parse_file_to_object() -> void:
	
	pass
