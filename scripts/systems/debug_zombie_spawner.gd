class_name DebugZombieSpawner
extends Node
## GEÇİCİ: dalga sistemi gelene kadar haritanın giriş noktalarından düzenli zombi doğurur.
## v0.1'in "sonsuz dalga" görevinde WaveManager ile değiştirilecek.

@export var zombie_types: Array[ZombieData] = []
## Saniye.
@export var interval: float = 1.5
@export var max_alive: int = 25

var pool: NodePool
var rng: RandomNumberGenerator
var spawn_points: Array[Vector2] = []
var target: Node2D
var target_health: HealthComponent

var _timer: float = 0.0
var _alive: int = 0


func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0 or _alive >= max_alive or spawn_points.is_empty() or zombie_types.is_empty():
		return
	_timer = interval
	var zombie: Zombie = pool.acquire()
	var data: ZombieData = zombie_types[rng.randi_range(0, zombie_types.size() - 1)]
	var point: Vector2 = spawn_points[rng.randi_range(0, spawn_points.size() - 1)]
	zombie.setup(data, target, target_health, point)
	if not zombie.died.is_connected(_on_zombie_died):
		zombie.died.connect(_on_zombie_died)
	_alive += 1


func _on_zombie_died(zombie: Zombie) -> void:
	_alive -= 1
	pool.release(zombie)
