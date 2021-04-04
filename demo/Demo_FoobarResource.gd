tool
extends Resource
class_name FoobarResource

var foo = 1.5 setget set_foo
var bar = "yum" setget set_bar
var baz = BazResource.new()

func set_foo(value):
	if foo == value:
		return
	foo = value
	emit_changed()

func set_bar(value):
	if bar == value:
		return
	bar = value
	emit_changed()

func _get_property_list() -> Array:
	return [
		{
			"name": "foo",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "-1.0, 1.0, 0.001",
		},
		{
			"name": "bar",
			"type": TYPE_STRING,
		},
		{
			"name": "baz",
			"type": TYPE_OBJECT,
		},
	]
