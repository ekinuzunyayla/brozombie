extends Node2D
## Oyun sahnesinin kökü: haritayı, oyuncuyu ve sistemleri birbirine bağlar.

## Run'ın tek rastgelelik kaynağı. Seed ileride run kaydına girer.
var rng := RandomNumberGenerator.new()

@onready var _map: GameMap = %Map
@onready var _player: Player = %Player
@onready var _bullet_pool: NodePool = %BulletPool
@onready var _zombie_pool: NodePool = %ZombiePool
@onready var _spawner: DebugZombieSpawner = %ZombieSpawner


func _ready() -> void:
	rng.randomize()
	_player.global_position = _map.player_spawn.global_position
	_fit_camera_to_map()
	_player.camera.reset_smoothing()
	_player.health.died.connect(_on_player_died)

	_player.weapon.pool = _bullet_pool
	_player.weapon.rng = rng

	_spawner.pool = _zombie_pool
	_spawner.rng = rng
	_spawner.spawn_points = _map.get_zombie_spawn_points()
	_spawner.target = _player
	_spawner.target_health = _player.health


func _fit_camera_to_map() -> void:
	var bounds: Rect2 = _map.get_bounds()
	var camera: Camera2D = _player.camera
	camera.limit_left = floori(bounds.position.x)
	camera.limit_top = floori(bounds.position.y)
	camera.limit_right = ceili(bounds.end.x)
	camera.limit_bottom = ceili(bounds.end.y)


# Ölüm ekranı gelene kadar run hemen baştan başlar.
func _on_player_died() -> void:
	get_tree().reload_current_scene.call_deferred()
