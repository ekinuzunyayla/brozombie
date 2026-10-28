class_name TouchActionButton
extends Control
## Dokunmatik ekranda bir input eylemini basılı tutan buton (ör. `interact`).
## Joystick'le aynı anda kullanılabilsin diye dokunmaları parmak index'iyle izler.

@export var action: StringName = &"interact"
## Butonun üstünde gösterilen çeviri anahtarı.
@export var label_key: String = ""

var _touch_index: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func is_held() -> bool:
	return _touch_index != -1


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var touch := event as InputEventScreenTouch
	if not touch:
		return
	if touch.pressed and _touch_index == -1 and _contains(touch.position):
		_touch_index = touch.index
		Input.action_press(action)
		queue_redraw()
	elif not touch.pressed and touch.index == _touch_index:
		_release()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree() and is_held():
		_release()


func _contains(global_point: Vector2) -> bool:
	var radius: float = minf(size.x, size.y) * 0.5
	return global_point.distance_to(global_position + size * 0.5) <= radius


func _release() -> void:
	_touch_index = -1
	Input.action_release(action)
	queue_redraw()


# Placeholder görünüm: daire ve etiket.
func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.5
	draw_circle(center, radius, Color(1, 1, 1, 0.35 if is_held() else 0.18))
	draw_arc(center, radius, 0.0, TAU, 48, Color(1, 1, 1, 0.6), 4.0)
	if label_key.is_empty():
		return
	var font: Font = get_theme_default_font()
	var font_size: int = 36
	var text: String = tr(label_key)
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, center + Vector2(-text_size.x * 0.5, font_size * 0.35), text,
			HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
