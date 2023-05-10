extends Control




@onready var rtl = $RichTextLabel




func _ready() -> void:
	
	var begin_msec	: int = 0
	var end_msec	: int = 0
	
	begin_msec = Time.get_ticks_msec()
	
	# =========================================
	
	#test( "res://toml_file/test_all.toml" )
	#test( "res://toml_file/test.toml" )
	test( "res://toml_file/list_array.toml" )
	
	# =========================================
	
	end_msec = Time.get_ticks_msec()
	
	# 解析耗时，单位：毫秒
	rtl.text += "time-consuming > " + str( end_msec - begin_msec ) + " (millisecond)"




func test( _load: String ) -> void:
	
	# 解析
	var toml: Dictionary = GTomlParseTool.parse_file( _load )
	
	# json格式化
	rtl.text += JSON.stringify( toml, "\t" ) + "\n\n"
