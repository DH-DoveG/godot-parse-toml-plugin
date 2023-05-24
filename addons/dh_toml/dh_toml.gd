
#===========================================
# 介绍：DHToml 插件，用于解析 .toml 文件
#      可以通过 .toml 来实例化对象，也可以将
#      对象序列化为 .toml 文件
# 
# 作者：DH-DoveG
#===========================================

@tool
extends EditorPlugin




func _enter_tree():
	
	# 启用插件时加载 DHTomlParseTool
	add_autoload_singleton("DHTomlParseTool", "res://addons/dh_toml/parse/dh_toml_parse.tscn")




func _exit_tree():
	
	# 关闭插件时卸载 DHTomlParseTool
	remove_autoload_singleton("DHTomlParseTool")
