extends Control



@onready var rtl = $RichTextLabel


func _ready() -> void:
	
	var time: String = ""
	
	time = Time.get_datetime_string_from_datetime_dict( Time.get_datetime_dict_from_system(), true )
	
	rtl.text += "BEGIN TIME > " + time + "\n\n"
	
	#test( "res://toml_file/test_all.toml" )
	#test( "res://toml_file/test.toml" )
	test( "res://toml_file/list_array.toml" )
	
	time = Time.get_datetime_string_from_datetime_dict( Time.get_datetime_dict_from_system(), true )
	
	rtl.text += "\n\nEND TIEM > " + time

func test( _load: String ) -> void:
	
	rtl.text += JSON.stringify( GTomlParseTool.parse_file( _load ), "\t" )
