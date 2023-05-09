
#===========================================
# 介绍：GToml 插件，用于解析 .toml 文件
#      可以通过 .toml 来实例化对象，也可以将
#      对象序列化为 .toml 文件
# 
# 作者：DH-DoveG
#===========================================

@tool
extends EditorPlugin




func _enter_tree():
	
	# 启用插件时加载 GTomlParseTool
	add_autoload_singleton( "GTomlParseTool", "res://addons/g_toml/parse/g_toml_parse.tscn" )




func _exit_tree():
	
	# 关闭插件时卸载 GTomlParseTool
	remove_autoload_singleton( "GTomlParseTool" )
