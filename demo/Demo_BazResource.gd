tool
extends Resource
class_name BazResource

var fizz = 50 setget set_fizz

func set_fizz(value):
	if fizz == value:
		return
	fizz = value
	emit_changed()

var buzz = 500.0 setget set_buzz

func set_buzz(value):
	if buzz == value:
		return
	buzz = value
	emit_changed()

func _get_property_list() -> Array:
	return [
		{
			"name": "fizz",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0, 2000, 1",
		},
		{
			"name": "buzz",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0.0, 1000.0, 0.2",
		},
	]
