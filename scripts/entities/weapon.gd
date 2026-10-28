class_name Weapon
extends Node2D
## Otomatik nişanlı silah. Menzildeki en yakın zombiye kendisi ateş eder, şarjör bitince doldurur.
## Değerler `WeaponData` tabanına sahibinin stat modifier'ları uygulanarak hesaplanır.

signal ammo_changed(current: int, magazine: int)
signal reload_started(duration: float)

@export var data: WeaponData

## Sahibinin statları (oyuncu). Kartlar buradan etki eder.
var owner_stats: Stats = Stats.new()
var pool: NodePool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _ammo: int = 0
var _cooldown: float = 0.0
var _reload_left: float = 0.0


func _ready() -> void:
	_ammo = get_magazine_size()


func get_ammo() -> int:
	return _ammo


func is_reloading() -> bool:
	return _reload_left > 0.0


## Dolumun ne kadarı bitti (0..1). Dolum yoksa 1.
func get_reload_progress() -> float:
	if not is_reloading():
		return 1.0
	return clampf(1.0 - _reload_left / maxf(0.01, get_reload_time()), 0.0, 1.0)


func get_damage() -> float:
	return owner_stats.apply(StatIds.DAMAGE, data.damage)


func get_attack_speed() -> float:
	return owner_stats.apply(StatIds.ATTACK_SPEED, data.attack_speed)


func get_range() -> float:
	return owner_stats.apply(StatIds.RANGE, data.max_range)


func get_magazine_size() -> int:
	return maxi(1, roundi(owner_stats.apply(StatIds.MAGAZINE_SIZE, data.magazine_size)))


func get_reload_time() -> float:
	return owner_stats.apply(StatIds.RELOAD_TIME, data.reload_time)


func get_crit_chance() -> float:
	return owner_stats.apply(StatIds.CRIT_CHANCE, data.crit_chance) / 100.0


func _physics_process(delta: float) -> void:
	if _reload_left > 0.0:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_ammo = get_magazine_size()
			ammo_changed.emit(_ammo, get_magazine_size())
		return
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target: Zombie = find_target()
	if target:
		_fire_at(target)


## Menzildeki en yakın canlı zombi. Yoksa null.
func find_target() -> Zombie:
	var best: Zombie = null
	var best_distance: float = get_range() * get_range()
	for node in get_tree().get_nodes_in_group(Zombie.GROUP):
		var zombie := node as Zombie
		if zombie == null or not zombie.is_alive():
			continue
		var distance: float = global_position.distance_squared_to(zombie.global_position)
		if distance <= best_distance:
			best = zombie
			best_distance = distance
	return best


func _fire_at(target: Zombie) -> void:
	var spread: float = deg_to_rad(data.spread_degrees)
	var angle: float = (target.global_position - global_position).angle() + rng.randf_range(-spread, spread)
	rotation = angle
	var damage: float = get_damage()
	if rng.randf() < get_crit_chance():
		damage *= data.crit_multiplier
	var bullet: Bullet = pool.acquire()
	bullet.launch(global_position, Vector2.from_angle(angle), data.projectile_speed, damage, get_range(), pool)
	_cooldown = 1.0 / maxf(0.01, get_attack_speed())
	_ammo -= 1
	ammo_changed.emit(_ammo, get_magazine_size())
	if _ammo <= 0:
		_reload_left = get_reload_time()
		reload_started.emit(_reload_left)
