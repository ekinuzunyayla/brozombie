extends GutTest
## Dokunmatik kontroller. GUT paneli 128. katmanda girdiyi yakaladığı için test edilen node
## 200. katmandaki bir CanvasLayer'a konur.

const TouchControlsScene: PackedScene = preload("res://scenes/ui/touch_controls.tscn")

var _layer: CanvasLayer
var _button: TouchActionButton


func before_each() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 200
	add_child_autofree(_layer)
	_button = TouchActionButton.new()
	_button.position = Vector2(100, 100)
	_button.size = Vector2(200, 200)
	_layer.add_child(_button)


func after_each() -> void:
	Input.action_release(&"interact")


func _touch(index: int, position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	return event


func test_touch_inside_presses_action() -> void:
	_button._input(_touch(0, Vector2(200, 200), true))
	assert_true(Input.is_action_pressed(&"interact"))


func test_touch_outside_circle_is_ignored() -> void:
	# Kare içinde ama dairenin dışında (köşe).
	_button._input(_touch(0, Vector2(105, 105), true))
	assert_false(Input.is_action_pressed(&"interact"))


func test_other_finger_release_keeps_action_held() -> void:
	_button._input(_touch(1, Vector2(200, 200), true))
	_button._input(_touch(0, Vector2(900, 500), false)) # Joystick parmağı kalktı.
	assert_true(Input.is_action_pressed(&"interact"))
	_button._input(_touch(1, Vector2(200, 200), false))
	assert_false(Input.is_action_pressed(&"interact"))


func test_hiding_releases_action() -> void:
	_button._input(_touch(0, Vector2(200, 200), true))
	_button.hide()
	assert_false(Input.is_action_pressed(&"interact"))


func test_joystick_drives_move_actions() -> void:
	var controls: Node = TouchControlsScene.instantiate()
	add_child_autofree(controls)
	var joystick: VirtualJoystick = controls.get_node("%MoveJoystick")
	assert_eq(joystick.action_left, MoveInput.ACTION_LEFT)
	assert_eq(joystick.action_right, MoveInput.ACTION_RIGHT)
	assert_eq(joystick.action_up, MoveInput.ACTION_UP)
	assert_eq(joystick.action_down, MoveInput.ACTION_DOWN)
	assert_eq(controls.get_node("%InteractButton").action, &"interact")
