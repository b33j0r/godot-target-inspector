# godot-target-inspector
An easy-to-use inspector control for Godot Engine based on Tree

![Screenshot of TargetInspector (2021-04-04-001)](https://github.com/b33j0r/godot-target-inspector/blob/main/doc/TargetInspector-2021-04-04-001.png?raw=true)

# Features
- [x] `TargetInspector` custom tree control
- [x] Set inspection target by assigning any object to `inspector.target`
- [x] Set inspection target by assigning a `NodePath` to `inspector.target_path`
- [x] Indexed properties work on targets specified as a `NodePath` (e.g. `/root/Game:player:inventory`)
- [x] Automatic two-way data binding
- [x] Event-driven updates if the target has a `changed` signal
- [x] Polling-driven updates if event-driven isn't available
- [-] Supported types
  - [x] `Node` and `Resource` (embedded/nested objects)
  - [x] `float` (supports ranges, but all three of `min`, `max`, `step` must be specified)
  - [x] `int` (supports ranges, but all three of `min`, `max`, `step` must be specified)
  - [x] `String`
  - [ ] `bool` (soon)
  - [ ] Vectors, Rect2, and other built-in dimensional types (soon)

# Usage

In addition to setting the exported target_path property within the
Godot editor, there are several ways to set the target in GDScript:

```
inspector.set_target(document)
inspector.set_target(self, "document.baz")
inspector.target_path = "%s:document" % [get_path()]
```

The UI works by creating a "virtual DOM" of `Node` objects which are mirrored
by a `Tree` and its `TreeNode` objects. One of the reasons this project was
created was to avoid the hassle of `Tree` working differently from everything
else in Godot.

Because of this design, it's straightforward to query and modify target
properties being watched by the inspector. Here's the easiest way to directly
modify a value:

```
inspector.set_inspector_node("foo", 5.1)
```

And these are all equivalent methods of getting an inspector node:

```
var fizz = inspector.get_inspector_node("baz.fizz")
var fizz = inspector.get_inspector_node("baz:fizz")
var fizz = inspector.get_inspector_node("baz/fizz")
var fizz = inspector.root.get_node("baz").get_node("fizz")
if fizz:
    fizz.set_value(1337.5)
```

### Author
Brian Jorgensen

### License
MIT
