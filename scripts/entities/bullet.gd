class_name Bullet
extends Area2D
## Oyuncu mermisi. Düz gider, ilk zombiye ya da duvara çarpınca havuza döner.

var _velocity: Vector2 = Vector2.ZERO
var _damage: float = 0.0
var _life: float = 0.0
var _active: bool = false
var _pool: NodePool


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func launch(from: Vector2, direction: Vector2, speed: float, damage: float, max_range: float, pool: NodePool) -> void:
	global_position = from
	rotation = direction.angle()
	_velocity = direction * speed
	_damage = damage
	_life = max_range / speed
	_pool = pool
	_active = true


func _physics_process(delta: float) -> void:
	if not _active:
		return
	position += _velocity * delta
	_life -= delta
	if _life <= 0.0:
		_finish()


func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	var zombie := body as Zombie
	if zombie:
		zombie.take_hit(_damage)
	_finish()


func _finish() -> void:
	_active = false
	if _pool:
		_pool.release(self)
	else:
		queue_free()
