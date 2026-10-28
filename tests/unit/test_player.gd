extends GutTest

const GameScene: PackedScene = preload("res://scenes/game/game.tscn")
const PlayerScene: PackedScene = preload("res://scenes/player/player.tscn")


func after_each() -> void:
	Input.action_release(MoveInput.ACTION_RIGHT)


func test_character_data_creates_base_stats() -> void:
	var data: CharacterData = load("res://data/characters/survivor.tres")
	var stats: Stats = data.create_stats()
	assert_gt(stats.get_value(StatIds.MOVE_SPEED), 0.0)
	assert_gt(stats.get_value(StatIds.MAX_HP), 0.0)
	for stat in data.base_stats:
		assert_has(StatIds.ALL, stat, "%s StatIds içinde yok" % stat)


func test_player_moves_with_input() -> void:
	var player: Player = PlayerScene.instantiate()
	add_child_autofree(player)
	Input.action_press(MoveInput.ACTION_RIGHT)
	await wait_physics_frames(20)
	assert_gt(player.position.x, 0.0)
	assert_almost_eq(player.position.y, 0.0, 0.01)


func test_player_speed_comes_from_stats() -> void:
	var player: Player = PlayerScene.instantiate()
	add_child_autofree(player)
	player.stats.add_modifier(StatModifier.create(StatIds.MOVE_SPEED, StatModifier.Type.PERCENT, -100.0))
	Input.action_press(MoveInput.ACTION_RIGHT)
	await wait_physics_frames(10)
	assert_almost_eq(player.position.x, 0.0, 0.01)


func test_player_stops_without_input() -> void:
	var player: Player = PlayerScene.instantiate()
	add_child_autofree(player)
	Input.action_press(MoveInput.ACTION_RIGHT)
	await wait_physics_frames(10)
	Input.action_release(MoveInput.ACTION_RIGHT)
	await wait_physics_frames(10)
	assert_almost_eq(player.velocity.length(), 0.0, 0.01)


func test_game_spawns_player_and_limits_camera() -> void:
	var game: Node = GameScene.instantiate()
	add_child_autofree(game)
	var map: GameMap = game.get_node("%Map")
	var player: Player = game.get_node("%Player")
	assert_eq(player.global_position, map.player_spawn.global_position)
	var bounds: Rect2 = map.get_bounds()
	assert_eq(player.camera.limit_left, int(bounds.position.x))
	assert_eq(player.camera.limit_bottom, int(bounds.end.y))


func test_player_cannot_walk_through_walls() -> void:
	var game: Node = GameScene.instantiate()
	add_child_autofree(game)
	var map: GameMap = game.get_node("%Map")
	var player: Player = game.get_node("%Player")
	Input.action_press(MoveInput.ACTION_RIGHT)
	await wait_physics_frames(240) # 4 saniye: iç duvara çarpmaya yeter.
	var bounds: Rect2 = map.get_bounds()
	assert_true(bounds.has_point(player.global_position), "Oyuncu haritanın dışına çıktı")
	var cell: Vector2i = map.walls.local_to_map(map.walls.to_local(player.global_position))
	assert_eq(map.walls.get_cell_source_id(cell), -1, "Oyuncu bir duvarın içinde")
