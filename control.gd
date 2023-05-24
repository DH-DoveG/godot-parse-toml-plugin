extends Control




@onready var rtl = $RichTextLabel




func _ready() -> void:
	
	#var reg: RegEx = RegEx.new()
	#reg.compile("/\\\\u([0-9A-Fa-f]{4})|\\\\U([0-9A-Fa-f]{8})/g")
	#var m: RegExMatch = reg.search("\\u4f60")
	#if m:
	#	print("m>", m.get_string())
	
	#var regex = "\\\\u([0-9a-fA-F]+){4}|\\\\u([0-9a-fA-F]+){8}"
	#var r = RegEx.new()
	#r.compile(regex)
	#var str = "\\u4f6123456789"#\\u597d!
	#var matc = r.search(str)
	#if matc:
	#	print(">>>>", matc.get_string())
	
	#print("\u4f60")
	
	var begin_msec	: int = 0
	var end_msec	: int = 0
	
	begin_msec = Time.get_ticks_msec()
	
	# =========================================
	
	#test("res://toml_file/test_all.toml")
	test("res://toml_file/test.toml")
	#test("res://toml_file/list_array.toml")
	#test("res://toml_file/unicode.toml")
	
	# =========================================
	
	end_msec = Time.get_ticks_msec()
	
	# 解析耗时，单位：毫秒
	rtl.text += "time-consuming > " + str(end_msec - begin_msec) + " (millisecond)"




func test(_load: String) -> void:
	
	# 解析
	var toml: Dictionary = DHTomlParseTool.parse_file(_load)
	
	# json格式化
	rtl.text += JSON.stringify(toml, "\t") + "\n\n"
