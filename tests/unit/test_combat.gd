extends GutTest
## Silah, mermi, zombi ve havuzun birlikte çalışması.

const ZombieScene: PackedScene = preload("res://scenes/zombies/zombie.tscn")
const BulletScene: PackedScene = preload("res://scenes/projectiles/bullet.tscn")
const PISTOL: WeaponData = preload("res://data/weapons/pistol.tres")
const WALKER: ZombieData = preload("res://data/zombies/walker.tres")
const RUNNER: ZombieData = preload("res://data/zombies/runner.tres")

var _world: Node2D
var _bullet_pool: NodePool
var _target: Node2D
var _target_health: HealthComponent


func before_each() -> void:
	_world = Node2D.new()
	add_child_autofree(_world)
	_bullet_pool = NodePool.new()
	_bullet_pool.scene = BulletScene
	_world.add_child(_bullet_pool)
	_target = Node2D.new()
	_world.add_child(_target)
	_target_health = HealthComponent.new()
	_target.add_child(_target_health)
	_target_health.reset(100.0)


func _spawn_zombie(data: ZombieData, at: Vector2, target: Node2D = null) -> Zombie:
	var zombie: Zombie = ZombieScene.instantiate()
	_world.add_child(zombie)
	zombie.setup(data, target, _target_health if target else null, at)
	return zombie


func _make_weapon() -> Weapon:
	var weapon := Weapon.new()
	weapon.data = PISTOL
	weapon.pool = _bullet_pool
	weapon.rng.seed = 1
	_world.add_child(weapon)
	return weapon


func test_zombie_data_is_valid() -> void:
	for data in [WALKER, RUNNER]:
		assert_gt(data.max_health, 0.0)
		assert_gt(data.speed, 0.0)
		assert_not_null(data.scene)
	assert_gt(RUNNER.speed, WALKER.speed, "Koşucu yürüyenden hızlı olmalı")


func test_weapon_ignores_zombies_out_of_range() -> void:
	var weapon := _make_weapon()
	_spawn_zombie(WALKER, Vector2(PISTOL.max_range + 200.0, 0))
	assert_null(weapon.find_target())


func test_weapon_targets_nearest_zombie() -> void:
	var weapon := _make_weapon()
	_spawn_zombie(WALKER, Vector2(400, 0))
	var near := _spawn_zombie(WALKER, Vector2(0, 150))
	assert_eq(weapon.find_target(), near)


func test_weapon_shoots_and_kills_zombie() -> void:
	var weapon := _make_weapon()
	var zombie := _spawn_zombie(RUNNER, Vector2(300, 0))
	watch_signals(zombie)
	await wait_seconds(1.5)
	assert_signal_emitted(zombie, "died")
	assert_lt(weapon.get_ammo(), PISTOL.magazine_size)


func test_dead_zombie_is_not_a_target() -> void:
	var weapon := _make_weapon()
	var zombie := _spawn_zombie(WALKER, Vector2(100, 0))
	zombie.take_hit(1000.0)
	assert_false(zombie.is_alive())
	assert_null(weapon.find_target())


func test_weapon_reloads_after_magazine() -> void:
	var weapon := _make_weapon()
	var tough := WALKER.duplicate()
	tough.max_health = 100000.0
	var zombie := _spawn_zombie(tough, Vector2(200, 0))
	watch_signals(weapon)
	await wait_seconds(PISTOL.magazine_size / PISTOL.attack_speed + 0.3)
	assert_signal_emitted(weapon, "reload_started")
	assert_true(weapon.is_reloading())
	zombie.take_hit(tough.max_health) # Dolum bitince hemen yeniden ateş etmesin.
	await wait_seconds(PISTOL.reload_time + 0.2)
	assert_eq(weapon.get_ammo(), PISTOL.magazine_size)


func test_player_damage_cards_affect_weapon() -> void:
	var weapon := _make_weapon()
	weapon.owner_stats.add_modifier(StatModifier.create(StatIds.DAMAGE, StatModifier.Type.PERCENT, 50.0))
	assert_almost_eq(weapon.get_damage(), PISTOL.damage * 1.5, 0.001)
	weapon.owner_stats.add_modifier(StatModifier.create(StatIds.RELOAD_TIME, StatModifier.Type.PERCENT, -20.0))
	assert_almost_eq(weapon.get_reload_time(), PISTOL.reload_time * 0.8, 0.001)


func test_bullets_return_to_pool() -> void:
	var weapon := _make_weapon()
	_spawn_zombie(RUNNER, Vector2(300, 0))
	await wait_seconds(1.5)
	var created: int = _bullet_pool.get_child_count()
	assert_gt(_bullet_pool.free_count(), 0)
	assert_lte(created, 8, "Mermiler yeniden kullanılmalı")
	assert_not_null(weapon)


func test_zombie_walks_to_target_and_attacks() -> void:
	var zombie := _spawn_zombie(RUNNER, Vector2(300, 0), _target)
	await wait_seconds(3.0)
	assert_lt(zombie.global_position.distance_to(_target.global_position), RUNNER.attack_range)
	assert_lt(_target_health.current, 100.0)


func test_zombie_attack_respects_interval() -> void:
	_spawn_zombie(WALKER, Vector2(10, 0), _target)
	await wait_seconds(WALKER.attack_interval * 2.5)
	# İlk vuruş bir aralık sonra; 2.5 aralıkta en fazla 2 vuruş.
	assert_gte(_target_health.current, 100.0 - WALKER.damage * 2)


func test_pool_reuses_released_node() -> void:
	var first: Node = _bullet_pool.acquire()
	_bullet_pool.release(first)
	await wait_process_frames(1)
	assert_eq(_bullet_pool.acquire(), first)
