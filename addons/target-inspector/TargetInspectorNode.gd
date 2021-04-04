tool
extends Node
class_name TargetInspectorNode

func get_class() -> String:
	return "TargetInspectorNode"

signal value_changed(value)

const DEFAULT_PROPERTY_INFO = {
	"name": "",
	"type": TYPE_NIL,
	"hint": PROPERTY_HINT_NONE,
	"hint_string": "",
	"usage": PROPERTY_USAGE_DEFAULT,
	"_meta": {
		"label": null,
	},
}

var property: String
var label: String
var last_value
var tree_item: TreeItem
var range_hint: Dictionary
var polling_period = 1.0

var _target: Object
var _property_info: Dictionary
var _enable_polling = false
var _poll_time_left = 0.0
var _dirty = true

func _init(target, property_info):
	_property_info = property_info if property_info else {}
	for k in DEFAULT_PROPERTY_INFO:
		if not k in _property_info:
			_property_info[k] = DEFAULT_PROPERTY_INFO[k]
	
	self._target = target
	self._property_info = _property_info
	self.property = _property_info.name
	if self.property:
		self.name = property
	self.range_hint = _parse_range_hint(_property_info.type, _property_info.hint, _property_info.hint_string)
	self.label = _property_info._meta.label if _property_info._meta.label != null else self.property

func _process(delta):
	if not Engine.editor_hint and not _dirty and _enable_polling:
		_poll_time_left -= delta
		if _poll_time_left <= 0.0:
			_update_value()
			_poll_time_left = polling_period
	
	if not _dirty:
		return
		
	if self._target:
		if self._target.has_signal("changed"):
			var _e = self._target.connect("changed", self, "_update_value")
			_enable_polling = false
		else:
			_enable_polling = true
		_dirty = false

func _to_string():
	return "TargetInspectorNode(parent=%s, name=%s, target=%s, property=%s, %s)" % [get_parent().name, name, _target, property, self.get_value()]

func get_property_info() -> Dictionary:
	return _property_info

func get_value():
	var value
	if _target and property:
		value = _target.get(property)
	return value

func set_value(value):
	if not (_target and property):
		return
	if value != null:
		match get_type():
			TYPE_REAL:
				value = float(value)
			TYPE_INT:
				value = int(value)
			TYPE_STRING:
				value = String(value)
	if value == last_value:
		return
	last_value = value
	_target.set(property, value)
	emit_signal("value_changed", value)

func get_type():
	return self._property_info.type

func _update_value():
	set_value(get_value())

func _parse_range_hint(type, hint, hint_string) -> Dictionary:
	if hint != PROPERTY_HINT_RANGE or not hint_string:
		return {"min": null, "max": null, "step": null, "specified": 0}
	var r = [null, null, null]
	var parts = hint_string.split(",")
	
	for i in int(clamp(parts.size(), 0, 3)):
		match type:
			TYPE_INT:
				r[i] = int(parts[i].strip_edges())
			TYPE_REAL:
				r[i] = float(parts[i].strip_edges())
	return {"min": r[0], "max": r[1], "step": r[2], "specified": parts.size()}
