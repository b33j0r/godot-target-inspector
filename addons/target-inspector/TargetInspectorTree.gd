tool
extends Tree

func get_class() -> String:
	return "TargetInspectorTree"

enum {COLUMN_RESET, COLUMN_NAME, COLUMN_VALUE, COLUMN_COUNT}

func _init():
	name = "Tree"

func _ready():
	rect_min_size.y = 20
	rect_min_size.x = 100
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var _e = connect("item_edited", self, "_on_item_edited")

func _enter_tree():
	var inspector: Node = get_parent() as Node
	var _e = inspector.connect("rebuild_tree", self, "rebuild_tree")
	_e = inspector.connect("value_changed", self, "_set_tree_control_value")

func _exit_tree():
	var inspector: Node = get_parent() as Node
	inspector.disconnect("rebuild_tree", self, "rebuild_tree")
	inspector.disconnect("value_changed", self, "_set_tree_control_value")

func rebuild_tree(root):
	clear()
	
	# It seems that clear() happens with call_deferred or similar;
	# if you repopulate the tree this frame, everything is deleted.
	yield(get_tree(), "idle_frame")
	
	_rebuild_tree_control(root, null)

func _configure_tree_control():
	hide_root = true
	columns = COLUMN_COUNT
	select_mode = Tree.SELECT_SINGLE
	
	set_column_expand(COLUMN_RESET, false)
	set_column_min_width(COLUMN_RESET, 15)
	
	set_column_expand(COLUMN_NAME, true)
	set_column_min_width(COLUMN_NAME, 60)
	
	set_column_expand(COLUMN_VALUE, true)
	set_column_min_width(COLUMN_VALUE, 60)


func _rebuild_tree_control(node, parent_tree_node):
	_configure_tree_control()
	
	var tree_item = create_item(parent_tree_node)
	node.tree_item = tree_item
	tree_item.set_metadata(COLUMN_VALUE, node)
	tree_item.set_text(COLUMN_NAME, node.label)
	tree_item.set_editable(COLUMN_VALUE, true)
	
	tree_item.set_expand_right(COLUMN_NAME, true)
	
	match node.get_type():
		TYPE_NIL, TYPE_OBJECT:
			tree_item.set_editable(COLUMN_VALUE, false)
			tree_item.set_selectable(COLUMN_VALUE, false)
		TYPE_INT:
			tree_item.set_cell_mode(COLUMN_VALUE, TreeItem.CELL_MODE_RANGE)
			if node.range_hint.specified == 3:
				tree_item.set_range_config(COLUMN_VALUE, node.range_hint.min, node.range_hint.max, node.range_hint.step)
		TYPE_REAL:
			tree_item.set_cell_mode(COLUMN_VALUE, TreeItem.CELL_MODE_RANGE)
			if node.range_hint.specified == 3:
				tree_item.set_range_config(COLUMN_VALUE, node.range_hint.min, node.range_hint.max, node.range_hint.step)
		TYPE_STRING:
			tree_item.set_text_align(COLUMN_VALUE, TreeItem.ALIGN_LEFT)
			tree_item.set_cell_mode(COLUMN_VALUE, TreeItem.CELL_MODE_STRING)
	
	_update_tree_control_value(tree_item)

	for child in node.get_children():
		_rebuild_tree_control(child, tree_item)

func _update_tree_control_value(tree_item, node=null):
	if node == null:
		node = tree_item.get_metadata(COLUMN_VALUE) as TargetInspectorNode
	var value = node.get_value()
	_set_tree_control_value(node, value)

func _get_tree_control_value(node):
	var current_value = null
	match node.get_type():
		TYPE_INT, TYPE_REAL:
			current_value = node.tree_item.get_range(COLUMN_VALUE)
		TYPE_STRING:
			current_value = node.tree_item.get_text(COLUMN_VALUE)
	return current_value

func _set_tree_control_value(node, value):
	if value == _get_tree_control_value(node):
		return
	match node.get_type():
		TYPE_INT, TYPE_REAL:
			node.tree_item.set_range(COLUMN_VALUE, value if (value != null) else -INF)
		TYPE_STRING:
			node.tree_item.set_text(COLUMN_VALUE, "%s" % [value if value else ""])

func _on_item_edited():
	var tree_item = get_edited()
	var tree_column = get_edited_column()
	
	var node = tree_item.get_metadata(tree_column)
	var value
	if node.get_type() in [TYPE_REAL, TYPE_INT]:
		value = tree_item.get_range(COLUMN_VALUE)
	else:
		value = tree_item.get_text(COLUMN_VALUE)
	node.set_value(value)
