extends GutTest

const GameScene: PackedScene = preload("res://scenes/game/game.tscn")

var _game: Node
var _hud: Hud
var _player: Player
var _original_locale: String


func before_each() -> void:
	_original_locale = Game.get_locale()
	_game = GameScene.instantiate()
	add_child_autofree(_game)
	_game.get_node("%ZombieSpawner").process_mode = Node.PROCESS_MODE_DISABLED
	_hud = _game.get_node("%Hud")
	_player = _game.get_node("%Player")


func after_each() -> void:
	Game.set_locale(_original_locale, false)


func test_shows_full_health_at_start() -> void:
	var maximum: int = roundi(_player.health.maximum)
	assert_eq(_hud.get_node("%HealthLabel").text, "%d / %d" % [maximum, maximum])
	assert_eq(_hud.get_node("%HealthBar").value, _player.health.maximum)


func test_health_updates_on_damage() -> void:
	_player.health.take_damage(25.0)
	var maximum: int = roundi(_player.health.maximum)
	assert_eq(_hud.get_node("%HealthLabel").text, "%d / %d" % [maximum - 25, maximum])
	assert_eq(_hud.get_node("%HealthBar").value, _player.health.maximum - 25.0)


func test_low_health_turns_bar_red() -> void:
	var fill: StyleBoxFlat = _hud.get_node("%HealthBar").get_theme_stylebox("fill")
	assert_eq(fill.bg_color, Hud.HEALTH_COLOR)
	_player.health.take_damage(_player.health.maximum * 0.8)
	assert_eq(fill.bg_color, Hud.LOW_HEALTH_COLOR)


func test_shows_full_magazine_at_start() -> void:
	var magazine: int = _player.weapon.get_magazine_size()
	assert_eq(_hud.get_node("%AmmoLabel").text, "%d / %d" % [magazine, magazine])


func test_ammo_updates_when_weapon_fires() -> void:
	_player.weapon.ammo_changed.emit(7, 12)
	assert_eq(_hud.get_node("%AmmoLabel").text, "7 / 12")


func test_reload_bar_only_visible_while_reloading() -> void:
	await wait_process_frames(2)
	assert_false(_hud.get_node("%ReloadBar").visible)


func test_wave_label_is_translated() -> void:
	Game.set_locale("tr", false)
	_hud.set_wave(3)
	assert_eq(_hud.get_node("%WaveLabel").text, "Dalga 3")
	Game.set_locale("en", false)
	assert_eq(_hud.get_node("%WaveLabel").text, "Wave 3")
