tool
extends EditorPlugin

const CUSTOM_TYPES = [
	{
		"type": "TargetInspector",
		"base": "VBoxContainer",
		"script": preload("res://addons/target-inspector/TargetInspector.gd"),
		"icon": preload("res://addons/target-inspector/TargetInspector.svg"),
	},
]

func _enter_tree():
	register_custom_types()

func _exit_tree():
	unregister_custom_types()

func register_custom_types():
	for custom_type in CUSTOM_TYPES:
		add_custom_type(custom_type.type, custom_type.base, custom_type.script, custom_type.icon)

func unregister_custom_types():
	for custom_type in CUSTOM_TYPES:
		remove_custom_type(custom_type.type)
