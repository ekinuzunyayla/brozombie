extends Node2D
## Oyun sahnesinin kökü: haritayı ve oyuncuyu bir araya getirir.

@onready var _map: GameMap = %Map
@onready var _player: Player = %Player


func _ready() -> void:
	_player.global_position = _map.player_spawn.global_position
	_fit_camera_to_map()
	_player.camera.reset_smoothing()


func _fit_camera_to_map() -> void:
	var bounds: Rect2 = _map.get_bounds()
	var camera: Camera2D = _player.camera
	camera.limit_left = floori(bounds.position.x)
	camera.limit_top = floori(bounds.position.y)
	camera.limit_right = ceili(bounds.end.x)
	camera.limit_bottom = ceili(bounds.end.y)
