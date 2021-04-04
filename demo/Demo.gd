tool
extends Control

# TODO: Implement Vector2, Vector3, Rect2, and bool

# This flag is a for a demo showing `inspector.target = OS`, but
# it's not very impressive without supporting a few more types
export var show_full_os_object = false
export var animation_fps = 30.0

var enabled = false

var document: FoobarResource
var window_info: WindowInfo

var left: TargetInspector
var center: TargetInspector
var right: TargetInspector
var right_lower: TargetInspector
var right_box: VBoxContainer

var t = 0.0
var _frame_time_left = 0.0

onready var inspectors = $Inspectors
onready var enable_animate_foo = $Options/HBoxContainer/AnimateFoo
onready var enable_animate_fizz = $Options/HBoxContainer/AnimateFizz

func _init():
	OS.center_window()
	
	document = FoobarResource.new()
	left = TargetInspector.new("LeftInspector")
	center = TargetInspector.new("CenterInspector")
	right = TargetInspector.new("RightInspector")
	right_lower = TargetInspector.new("RightLowerInspector")
	right_lower.rect_min_size.x = 330
	
	right_box = VBoxContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	window_info = WindowInfo.new()

func _ready():
	inspectors.add_child(left)
	inspectors.add_child(center)
	inspectors.add_child(right_box)
	right_box.add_child(right)
	right_box.add_child(right_lower)
	
	left.target_path = "%s:document" % [get_path()]
	center.set_target(document)
	right.set_target(self, "document.baz")
	if show_full_os_object:
		right_lower.set_target(OS)
	else:
		right_lower.set_target(window_info)
	
	yield(get_tree(), "idle_frame")
	enabled = true

func _process(delta):
	t += delta
	
	_frame_time_left -= delta
	if _frame_time_left >= 0.0:
		return
	_frame_time_left = 1.0 / float(animation_fps)
	
	if not (enabled and enable_animate_fizz and enable_animate_foo):
		return
	
	var fx_sine = pow(cos(t * 0.5), 3.0)
	var fx_ramp = fmod(t * 0.01, 1.0)
	
	if enable_animate_foo.pressed:
		# Here's the easiest way to directly modify a value pointed to by an inspector:
		center.set_inspector_node("foo", 1.0 * fx_sine)

	if enable_animate_fizz.pressed:
		# These are all equivalent methods of getting an inspector node:
		var fizz = center.get_inspector_node("baz.fizz")
#		var fizz = center.get_inspector_node("baz:fizz")
#		var fizz = center.get_inspector_node("baz/fizz")
#		var fizz = center.root.get_node("baz").get_node("fizz")
		
		if fizz:
			fizz.set_value(1337.5 * fx_ramp)
