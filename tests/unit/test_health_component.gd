extends GutTest

var _health: HealthComponent


func before_each() -> void:
	_health = HealthComponent.new()
	add_child_autofree(_health)
	_health.reset(50.0)


func test_reset_fills_health() -> void:
	assert_eq(_health.current, 50.0)
	assert_false(_health.is_dead())


func test_damage_reduces_health() -> void:
	_health.take_damage(20.0)
	assert_eq(_health.current, 30.0)


func test_died_emits_once() -> void:
	watch_signals(_health)
	_health.take_damage(40.0)
	_health.take_damage(40.0)
	_health.take_damage(40.0)
	assert_signal_emit_count(_health, "died", 1)
	assert_eq(_health.current, 0.0)


func test_heal_is_capped_at_maximum() -> void:
	_health.take_damage(10.0)
	_health.heal(100.0)
	assert_eq(_health.current, 50.0)


func test_dead_cannot_be_healed() -> void:
	_health.take_damage(100.0)
	_health.heal(10.0)
	assert_true(_health.is_dead())


func test_reset_revives() -> void:
	_health.take_damage(100.0)
	_health.reset(30.0)
	assert_false(_health.is_dead())
	assert_eq(_health.current, 30.0)
