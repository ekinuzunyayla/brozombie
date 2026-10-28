class_name TouchControls
extends CanvasLayer
## Sanal joystick ve etkileşim butonu. Yalnızca dokunmatik ekranı olan cihazlarda görünür.

@onready var _root: Control = %SafeArea


func _ready() -> void:
	_root.visible = DisplayServer.is_touchscreen_available()
