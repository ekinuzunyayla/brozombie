class_name MoveInput
extends RefCounted
## Hareket girdisinin tek kaynağı. Klavye, gamepad ve dokunmatik joystick aynı `move_*` eylemlerini
## besler (dokunmatikte Godot'nun yerleşik `VirtualJoystick` node'u). Oyuncu kodu girdinin
## nereden geldiğini bilmez, yalnızca `get_vector()` okur.

const ACTION_LEFT: StringName = &"move_left"
const ACTION_RIGHT: StringName = &"move_right"
const ACTION_UP: StringName = &"move_up"
const ACTION_DOWN: StringName = &"move_down"


## Uzunluğu 0..1 arasında hareket yönü. Ölü bölge input map'teki eylemlerden gelir.
static func get_vector() -> Vector2:
	return Input.get_vector(ACTION_LEFT, ACTION_RIGHT, ACTION_UP, ACTION_DOWN)
