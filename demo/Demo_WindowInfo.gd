tool
extends Object
class_name WindowInfo

var title = "godot-target-inspector" setget set_title, get_title
var width setget set_width, get_width
var height setget set_height, get_height

func set_title(value):
	title = value
	OS.set_window_title(title)
func get_title(): return title
func set_width(value): OS.window_size.x = value
func get_width(): return OS.window_size.x
func set_height(value): OS.window_size.y = value
func get_height(): return OS.window_size.y

func _get_property_list():
	return [
		{
			"_meta": {
				"label": "Window Title",
			},
			"name": "title",
			"type": TYPE_STRING,
		},
		{
			"_meta": {
				"label": "Window Width",
			},
			"name": "width",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "490, 1200, 1",
		},
		{
			"_meta": {
				"label": "Window Height",
			},
			"name": "height",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "200, 1000, 1",
		},
	]
