tool
extends VBoxContainer
class_name TargetInspector

func get_class() -> String:
	return "TargetInspector"

signal rebuild_tree(root)
signal value_changed(node, value)

export(NodePath) var target_path setget set_target_path
export(bool) var enable_warnings = false

const TargetInspectorTree = preload("res://addons/target-inspector/TargetInspectorTree.gd")

var tree: Tree
var root: Node
var ignored_properties = []
var custom_property_list_method = "_get_inspector_properties"
	
var _name
var _target
var _warnings = {} # used to only warn once for each path in get_inspector_node/set_inspector_value
var _dirty = false # tracks whether we have found the target node

func _init(name=null, ignore_default_properties=true):
	_name = name
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if ignore_default_properties:
		_init_default_ignored_properties()
	_init_root()
	_init_tree()

func _init_root():
	if root:
		remove_child(root)
	root = TargetInspectorNode.new(null, null)
	add_child(root)
	root.name = "Root"

func _init_tree():
	tree = get_node_or_null("Tree")
	if not tree:
		tree = TargetInspectorTree.new()
		tree.name = "Tree"
		add_child(tree)
	
func _enter_tree():
	if _name != null:
		name = _name

func _ready():
	rebuild()

func _process(_delta):
	if _dirty:
		_rebuild()

func get_inspector_properties(o):
	if not o is Object:
		return []
	var property_list_methods = [custom_property_list_method, "_get_property_list", "get_property_list"]
	for method in property_list_methods:
		if not o.has_method(method):
			continue
		return o.call(method)
	return []

func _init_default_ignored_properties():
	ignored_properties.append("Script Variables")
	for cls in [Node, Resource]:
		var sacrificial_node = cls.new()
		for p in sacrificial_node.get_property_list():
			ignored_properties.append(p.name)

func set_target_path(value):
	if target_path == value:
		return
	target_path = value
	rebuild()

func set_target(target, field=""):
	if not target:
		_target = null
		set_target_path(null)
	elif target is Node:
		var path = target.get_path()
		set_target_path_and_field(path, field)
	else:
		_target = target
		set_target_path(null)
		rebuild()

func set_target_path_and_field(path, field):
	if field != "":
		field = field.replace(".", ":")
		path = "%s:%s" % [path, field]
	set_target_path(path)
	_target = _get_target_from_path()
	rebuild()

func has_target():
	return get_target() != null

func get_target():
	if not _target:
		_target = _get_target_from_path()
	return _target

func _get_target_from_path():
	if not target_path:
		return null
	var parts = get_node_and_resource(target_path)
	var node = parts[0]
	var resource = parts[1]
	if resource:
		return resource
	return node

func get_inspector_node(path: String) -> TargetInspectorNode:
	if not root:
		return null
	var node_path = path.replace(".", "/").replace(":", "/")
	var node = root.get_node_or_null(node_path)
	if node != null:
		return node as TargetInspectorNode
	# The node didn't exist, warn the first time per path
	if enable_warnings and not ("get:" + path) in _warnings:
		_warnings[("get:" + path)] = ""
		push_warning("get_inspector_node failed (inspector: %s, path: %s)" % [get_path(), path])
	return null
	
func set_inspector_node(path: String, value):
	var node = get_inspector_node(path)
	if node:
		node.set_value(value)
	elif enable_warnings and not ("set:" + path) in _warnings:
		# The node didn't exist, warn the first time per path
		_warnings[("set:" + path)] = value
		push_warning("set_inspector_node failed (inspector: %s, path: %s, value: %s)" % [get_path(), path, value])

func rebuild():
	set_deferred("_dirty", true)

func _rebuild():
	var target = get_target()
	if not target:
		return
	
	_init_root()
	_rebuild_node(root, target)
	emit_signal("rebuild_tree", root)
	
	_dirty = false

func _rebuild_node(parent, target):
	if not target:
		return
	var props = get_inspector_properties(target)
	for prop in props:
		if "usage" in prop and not (prop.usage & PROPERTY_USAGE_DEFAULT):
			continue
		if prop.name in ignored_properties:
			continue
		var node = TargetInspectorNode.new(target, prop)
		parent.add_child(node)
		node.connect("value_changed", self, "_on_value_changed", [node])
		var value = node.get_value()
		if (value is Node) or (value is Resource):
			_rebuild_node(node, value)

func _on_value_changed(value, node):
	emit_signal("value_changed", node, value)
